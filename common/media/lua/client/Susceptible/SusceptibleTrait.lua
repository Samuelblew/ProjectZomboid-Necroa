require "Susceptible/SusceptibleMaskData"
require "Susceptible/SusceptibleUi"
local SusUtil = require "Susceptible/SusceptibleUtil"


-- Função auxiliar chamada em cada atualização do jogador. Evita reaplicação desnecessária do traço Susceptible.
local function otherCode()
    if isReapplyingSusceptible then
        -- Susceptible 특성 재적용
        return
    end
end

if not SusceptibleMod then
    SusceptibleMod = {
        uiByPlayer = {},
        threatByPlayer = {},
    }
end

local BASE_INFECTION_DISTANCE = 9;
local INFECTION_ROLLS_PER_SECOND = 10 -- This number should evenly divide 60. Not a hard requirement, but nicer.
local maskItems = SusceptibleMaskItems;

-- Retorna o item de máscara equipado pelo jogador e seus dados, priorizando máscaras não quebradas e de maior prioridade.
function SusceptibleMod.getEquippedMaskItemAndData(player)
    local items = player:getInventory():getItems();
    local foundItem = nil;
    local foundMask = nil;
    local priorityItemID = SusUtil.getPriorityMaskID(player);

    for i = 0, items:size()-1 do
        local item = items:get(i);
        if player:isEquippedClothing(item) then
            local mask = maskItems:getMaskData(item);
            if mask then
                if SusUtil.isBroken(item) then
                    if not foundItem then
                        foundItem = item;
                        foundMask = mask;
                    end
                else
                    if item:getID() == priorityItemID then
                        return item, mask;
                    else
                        foundItem = item;
                        foundMask = mask;
                    end
                end
            end
        end
    end

    return foundItem, foundMask;
end

-- Retorna uma lista de todos os itens de máscara no inventário do jogador.
function SusceptibleMod.getAllMaskItems(player)
    local items = player:getInventory():getItems();
    local foundItems = {};

    for i = 0, items:size()-1 do
        local item = items:get(i);
        local mask = maskItems:getMaskData(item);
        if mask then
            table.insert(foundItems, item);
        end
    end

    return foundItems;
end

-- Controla a frequência de atualização da lógica de infecção para cada jogador, usando um contador salvo em ModData.
function SusceptibleMod.shouldPlayerUpdate(player, playerData) 
    local playerData = player:getModData();
    if not playerData.susceptibleUpdateCounter then
        playerData.susceptibleUpdateCounter = 0;
    end

    playerData.susceptibleUpdateCounter = playerData.susceptibleUpdateCounter + 1;
    if playerData.susceptibleUpdateCounter < (60 / INFECTION_ROLLS_PER_SECOND) then
        return false;
    else
        playerData.susceptibleUpdateCounter = 0;
        return true;
    end
end

-- Função principal chamada a cada atualização do jogador. Calcula ameaça, atualiza a interface, verifica chance de infecção e aplica infecção se necessário.
function SusceptibleMod.onPlayerUpdate(player)
    if not SusceptibleMod.isPlayerSusceptible(player) or not SusceptibleMod.shouldPlayerUpdate(player) then
        return;
    end
    
    local infectionRoll = ZombRandFloat(0.0, 1.0);
    local threatLevel, _ = SusceptibleMod.calculateThreat(player)

    SusceptibleMod.updateMaskInfoDisplay(player, threatLevel)
    SusceptibleMod.threatByPlayer[player] = threatLevel;

    local activeThreatLevel = SusceptibleMod.reduceThreatWithMask(player, threatLevel);
    if activeThreatLevel > 0 then

    if SandboxVars.Susceptible.stress and player:HasTrait("Susceptible") then
        local stress = player:getStats():getStress();
        if stress < 1 then
            player:getStats():setStress(stress + activeThreatLevel / 50);
        end
    end

        local infectionChance = SusceptibleMod.calculateInfectionChance(player, activeThreatLevel);
        --print(infectionChance)

        if infectionRoll < infectionChance then
            if SusceptibleMod.tryLuckySave(player, activeThreatLevel) then
                return;
            end

            if SandboxVars.Susceptible.InstantDeath then
                player:Kill(player);
            else
                SusceptibleMod.infectPlayer(player)
            end
        end
    end
end

-- Infecta o jogador, marcando o torso como infectado.
function SusceptibleMod.infectPlayer(player)
    player:getBodyDamage():getBodyPart(BodyPartType.Torso_Upper):SetInfected(true);
end

-- Se o jogador tem o traço Lucky, pode evitar a infecção uma vez a cada 24 horas do jogo, com chance igual à de infecção.
function SusceptibleMod.tryLuckySave(player, infectionChance)
    if not player:HasTrait("Lucky") then
        return false;
    end

    local playerData = player:getModData();
    local time = getGameTime();

    if not playerData.lastLuckySave or playerData.lastLuckySave <= time:getWorldAgeHours() - 24 then
        playerData.lastLuckySave = time:getWorldAgeHours();
        local infectionRoll = ZombRandFloat(0.0, 1.0);
        return infectionRoll < infectionChance;
    end

    return false;
end

-- Calcula o nível de ameaça de infecção baseado na proximidade e visibilidade de zumbis, ambiente e modificadores de veículo.
function SusceptibleMod.calculateThreat(player)
    local infectionDistance = SusceptibleMod.calculateInfectionDistance(player);
    local isOutside = player:isOutside();

    local threatLevel = 0;
    local paranoiaLevel = 0;

    local multiplier = 1;
    if player:getVehicle() then
        multiplier = SusceptibleMod.calculateVehicleInfectionMultiplier(player, player:getVehicle());
    end
    
    if multiplier == 0 then
        return 0, 0;
    end

    local zeds = getCell():getZombieList();
    if zeds:size() > 0 then
        for i = 0, zeds:size() - 1 do
            local zombie = zeds:get(i);
            local distance = player:DistTo(zombie);
            if distance <= infectionDistance then
                if zombie:isUseless() then
                    paranoiaLevel = paranoiaLevel + 2
                elseif SusceptibleMod.zombieIsValid(player, zombie, distance, isOutside) then
                    if distance < 1 then
                        threatLevel = threatLevel + 2;
                    else
                        threatLevel = threatLevel + (2 / (0.75 + distance * 0.25));
                    end
                end
            end
        end
    end

    return threatLevel * multiplier, paranoiaLevel * multiplier;
end

-- Calcula a chance de infecção do jogador, levando em conta traços e o nível de ameaça.
function SusceptibleMod.calculateInfectionChance(player, threatLevel)
    local infectionChance = SandboxVars.Susceptible.BaseInfectionChance;
    if player:HasTrait("ProneToIllness") then
        infectionChance = infectionChance * 1.5;
    end
    if player:HasTrait("Resilient") then
        infectionChance = infectionChance * 0.6666;
    end

    if threatLevel < 1 then
        return infectionChance * threatLevel;
    else
        local safetyChance = (1 - infectionChance)^threatLevel;
        return 1 - safetyChance;
    end
end

-- Calcula a distância máxima para infecção, ajustando por traços e se o jogador está ao ar livre.
function SusceptibleMod.calculateInfectionDistance(player)
    local infectionDistance = BASE_INFECTION_DISTANCE;
    if player:isOutside() then
        infectionDistance = infectionDistance - 2;
    end
    if player:HasTrait("ProneToIllness") then 
        infectionDistance = infectionDistance + 2;
    end
    if player:HasTrait("Resilient") then 
        infectionDistance = infectionDistance - 2;
    end
    return infectionDistance;
end

local WINDOW_IDS = {
    "WindowFrontLeft",
    "WindowFrontRight",
    "WindowRearLeft",
    "WindowRearRight"
}

-- Calcula o multiplicador de ameaça de infecção quando o jogador está em um veículo, considerando janelas e velocidade.
function SusceptibleMod.calculateVehicleInfectionMultiplier(player, vehicle)
    local mult = SusceptibleMod.calculateVehicleInfectionMultiplierInternal(player, vehicle)
    if mult > 1 then
        mult = 1
    end
    return mult
end

-- Lógica detalhada para calcular o multiplicador de infecção em veículos, considerando janelas quebradas/abertas e direção.
function SusceptibleMod.calculateVehicleInfectionMultiplierInternal(player, vehicle)
    local speed = vehicle:getCurrentSpeedKmHour() / 16;
    if speed == 0 then
        speed = 1
    end

    if math.abs(speed) < 1 then
        speed = speed/math.abs(speed); -- sets speed to 1, but preserves sign
    end

    local windshield = vehicle:getPartById("Windshield");
    local windshieldDestroyed = (not windshield or not windshield:getWindow() or windshield:getWindow():isDestroyed());

    local rearWindshield = vehicle:getPartById("WindshieldRear"); 
    local rearWindshieldDestroyed = rearWindshield and rearWindshield:getWindow() and rearWindshield:getWindow():isDestroyed(); -- Not vehicles have rear windshields

    local infectionMult = 0; -- Start with full protection

    if windshieldDestroyed and not rearWindshieldDestroyed and speed < 0 then
        return 1.0 / -speed;
    elseif not windshieldDestroyed and rearWindshieldDestroyed and speed > 0 then
        return 1.0 / speed;
    elseif windshieldDestroyed or rearWindshieldDestroyed then
        return 0.85;
    end

    if infectionMult == 0 then
        for _, windowId in ipairs(WINDOW_IDS) do
            local windowPart = vehicle:getPartById(windowId);
            if windowPart then
                local window = windowPart:getWindow();
                if window and (window:isOpen() or window:isDestroyed()) then
                    return 0.8 / math.abs(speed);
                end
            end
        end
    end
    return infectionMult;
end

-- Verifica se um zumbi é uma ameaça válida para o jogador (mesmo andar, visível, não é NPC, etc).
function SusceptibleMod.zombieIsValid(player, zombie, distance, playerIsOutside)
    -- No infection across floors
    if player:getZ() ~= zombie:getZ() then
        return false;
    end
	
    if zombie:getVariableBoolean("Bandit") then return false end
	if zombie:getVariableBoolean("NPC") then return false end

    -- Ignore if not in the same environment and more than 2 tiles away
    local outdoorMismatch = playerIsOutside ~= zombie:isOutside();
    if outdoorMismatch and distance > 2 then
        return false;
    end

    -- Out of sight, out of mind
    local canSee = zombie:CanSee(player) or player:CanSee(zombie);
    if not canSee then
        return false;
    end

    -- If we're both outside and see each other, don't bother with pathfinding
    if playerIsOutside and not outdoorMismatch then
        return true;
    end

    -- Dumb pathfind straight at the player
    local cell = getCell();
    local zombieSqr = zombie:getSquare();
    local playerSqr = player:getSquare();
    local z = playerSqr:getZ();
    while playerSqr ~= nil and not playerSqr:equals(zombieSqr) do
        playerSqr = SusceptibleMod.stepTowardsTargetIfNotBlocked(cell, z, playerSqr, zombieSqr);
    end
    return playerSqr ~= nil; -- If we make it here and playerSqr is not nil, we found a straight path
end

-- Caminha em linha reta do jogador ao zumbi, parando se houver bloqueio.
function SusceptibleMod.stepTowardsTargetIfNotBlocked(cell, z, currentSqr, targetSqr)
    local xDiff = targetSqr:getX() - currentSqr:getX();
    local yDiff = targetSqr:getY() - currentSqr:getY();

    if xDiff == 0 and yDiff == 0 then
        return targetSqr;
    end

    if xDiff > 0 then
        xDiff = 1
    elseif xDiff < 0 then
        xDiff = -1
    end

    if yDiff > 0 then
        yDiff = 1
    elseif yDiff < 0 then
        yDiff = -1
    end

    local nextSquare = cell:getGridSquare(currentSqr:getX() + xDiff, currentSqr:getY() + yDiff, z);
    if not currentSqr:isBlockedTo(nextSquare) then
        return nextSquare;
    end
    return nil;
end

-- Reduz o nível de ameaça com base na máscara equipada, danificando a máscara conforme o uso.
function SusceptibleMod.reduceThreatWithMask(player, threatLevel)
    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if not mask or SusUtil.isBroken(item) then
        return threatLevel;
    end

    local maskDamageRate = SandboxVars.Susceptible.MaskDamageRate / (100 * INFECTION_ROLLS_PER_SECOND);

    if mask.repairType == SusceptibleRepairTypes.OXYGEN then
        local condition = item:getCondition() / item:getConditionMax() + 0.1;
        condition = condition * condition;
        if condition > 1 then
            condition = 1;
        end

        local conditionMult = 1.0 / condition; -- You're leaking :)
        SusceptibleMod.damageMask(item, mask, maskDamageRate * 2.75 * conditionMult); -- Constant drain rate for oxygen based protection
        return 0;
    else
        local damage = (threatLevel^0.65) * maskDamageRate * 2;
        SusceptibleMod.damageMask(item, mask, damage);
        if mask.quality then
            return threatLevel - (mask.quality * SandboxVars.Susceptible.MaskFilteringPower);
        else
            return 0;
        end
    end
end

-- Chama a função de drenagem de máscara para todos os jogadores periodicamente.
function SusceptibleMod.onGasMaskDrain()
    local players = IsoPlayer.getPlayers();
    for i = 0, players:size()-1 do
        SusceptibleMod.onPlayerGasMaskDrain(players:get(i));
    end
end

-- Drena a durabilidade da máscara do jogador com base em sua resistência.
function SusceptibleMod.onPlayerGasMaskDrain(player)
    if not player or not SusceptibleMod.isPlayerSusceptible(player) then
        return;
    end

    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player);
    if mask and not SusUtil.isBroken(item) then
        local damage = 0.04 * (2 - player:getStats():getEndurance());
        SusceptibleMod.damageMask(item, mask, damage);
    end
end

-- Aplica dano à durabilidade da máscara.
function SusceptibleMod.damageMask(item, mask, damage)
    SusUtil.damageDurability(item, damage);
end

-- Cria e exibe a interface da máscara para o jogador.
function SusceptibleMod.createMaskUi(player)
    if player:isDead() then
        return;
    end

    local ui = SusceptibleUi:new(0, 0, player:getPlayerNum())
    ui:initialise();
    ui:addToUIManager();
    SusceptibleMod.uiByPlayer[player] = ui;

    SusceptibleMod.applyUiOffsets();
end

-- Reposiciona a interface da máscara.
function SusceptibleMod.reloadUiPosition()
    SusceptibleMod.applyUiOffsets()
end

-- Aplica os deslocamentos de posição da interface para todos os jogadores, considerando o tipo de tela dividida.
function SusceptibleMod.applyUiOffsets()
    local offsetX, offsetY = SusUtil.loadUiOffsets()

    local splitScreenType = SusUtil.getSplitScreenType();
    if splitScreenType == "CROSS" or splitScreenType == "VERTICAL" then
        offsetX = (offsetX / 2.0);
    end
    if splitScreenType == "CROSS" then
        offsetY = (offsetY / 2.0);
    end

    for p,ui in pairs(SusceptibleMod.uiByPlayer) do
        local x = getPlayerScreenLeft(p:getPlayerNum());
        local y = getPlayerScreenTop(p:getPlayerNum());
        ui:setX(x + offsetX);
        ui:setY(y + offsetY);
    end
end

-- Remove a interface da máscara do jogador (ex: ao morrer).
function SusceptibleMod.removeUi(player)
    if SusceptibleMod.uiByPlayer[player] then
        local ui = SusceptibleMod.uiByPlayer[player];
        ui:destroyUi();
        SusceptibleMod.uiByPlayer[player] = nil;
    end
end

-- Atualiza a interface da máscara com informações sobre o item, ameaça e durabilidade.
function SusceptibleMod.updateMaskInfoDisplay(player, threatLevel)
    if player:isDead() then
        return;
    end

    local item, mask = SusceptibleMod.getEquippedMaskItemAndData(player)
    local playerData = player:getModData();

    if not SusceptibleMod.uiByPlayer[player] then
        SusceptibleMod.createMaskUi(player);
    end

    local quality = 99999;
    if mask and mask.quality then
        quality = mask.quality;
    end

    local isBroken = not item or SusUtil.isBroken(item);
    local threatValue = threatLevel;
    if not isBroken then
        threatValue = threatLevel / (quality * SandboxVars.Susceptible.MaskFilteringPower);
    end
      
    SusceptibleMod.uiByPlayer[player]:updateMaskImage(item, mask, threatValue, isBroken)

    if item and not isBroken then
        SusceptibleMod.uiByPlayer[player]:updateMaskInfo(true, SusUtil.getNormalizedDurability(item), threatValue)
    else
        SusceptibleMod.uiByPlayer[player]:updateMaskInfo(false, 0, threatLevel*2.5)
    end
end

-- Retorna se o jogador é suscetível (tem o traço ou a opção de sandbox está ativada).
function SusceptibleMod.isPlayerSusceptible(player)
    return SandboxVars.Susceptible.EveryoneIsSusceptible or player:HasTrait("Susceptible");
end

Events.OnPlayerUpdate.Add(SusceptibleMod.onPlayerUpdate);
Events.EveryTenMinutes.Add(SusceptibleMod.onGasMaskDrain);
Events.OnPlayerDeath.Add(SusceptibleMod.removeUi);

Events.OnResolutionChange.Add(SusceptibleMod.reloadUiPosition);
Events.OnCreatePlayer.Add(SusceptibleMod.reloadUiPosition);
Events.OnPlayerUpdate.Add(otherCode)  

