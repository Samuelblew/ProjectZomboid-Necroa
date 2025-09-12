local lastItems = {} -- (opcional) mantém estado anterior do inventário
local lastTransferTime = {} -- tabela [playerKey] = timestamp da última transferência que iniciou cooldown

-- 🔹 Configuração
local NO_GLOVE_SAFE_CHANCE = 70   -- chance % de escapar sem luvas
local MAX_CALC_HOLES = 2          -- máximo de buracos considerado na luva
local REDUCTION_PER_HOLE = 10     -- % de redução por buraco
local SPEAK_COOLDOWN = 7          -- cooldown em segundos (agora 7s)

-- Helper para criar uma chave estável por jogador (suporta single e multiplayer)
local function getPlayerKey(player)
    if player.getOnlineID then
        local id = player:getOnlineID()
        if id and id ~= -1 then return "online_" .. tostring(id) end
    end
    if player.getPlayerNum then
        return "local_" .. tostring(player:getPlayerNum())
    end
    return tostring(player)
end

-- Scan (mantive caso você use para outra coisa)
local function scanInventory(player)
    local inventory = player:getInventory()
    local items = inventory:getItems()
    local currentItems = {}

    for i = 0, items:size()-1 do
        local item = items:get(i)
        currentItems[item:getID()] = item
    end

    lastItems = currentItems
end

Events.OnPlayerUpdate.Add(scanInventory)

-- Hook da ação de transferir item
local old_perform = ISInventoryTransferAction.perform

function ISInventoryTransferAction:perform()
    local player = self.character
    local item = self.item
    local container = self.srcContainer

    -- só nos casos em que o item vem do inventário do zumbi
    local containerType = "nil"
    if container and container.getType then
        containerType = container:getType()
    end

    if containerType == "inventorymale" or containerType == "inventoryfemale" then
        local pid = getPlayerKey(player)
        local currentTime = os.time()
        local prevTransfer = lastTransferTime[pid] or 0
        local allowedToSpeak = (prevTransfer == 0) or (currentTime - prevTransfer >= SPEAK_COOLDOWN)

        -- Detecta Hazmat (proteção total)
        local hasHazmat = false
        local wornItems = player:getWornItems()
        for i = 0, wornItems:size() - 1 do
            local entry = wornItems:get(i)
            local wItem = entry and entry:getItem()
            if wItem and wItem:getFullType() == "Base.HazmatSuit" then
                hasHazmat = true
                break
            end
        end

        -- Decide mensagem e chance de escape
        local speakMessage = nil
        local safeChance = NO_GLOVE_SAFE_CHANCE -- default sem luva

        local glove = player:getWornItem("Hands")
        if glove then
            local holes = glove:getHolesNumber() or 0

            if holes >= MAX_CALC_HOLES then
                -- luva muito danificada → tratar como sem luva
                safeChance = NO_GLOVE_SAFE_CHANCE
                speakMessage = "I shouldn't be touching zombies like this, my gloves have holes!"
            else
                safeChance = math.max(0, 100 - (holes * REDUCTION_PER_HOLE))
                if holes > 0 then
                    speakMessage = "I shouldn't be touching zombies like this, my gloves have holes!"
                end
            end
        else
            -- sem luvas
            safeChance = NO_GLOVE_SAFE_CHANCE
            speakMessage = "I shouldn't be touching zombie stuff with bare hands!"
        end

        -- START/RESET cooldown: a transferência atual inicia o cooldown agora
        -- (isto impede falas nas próximas transferências dentro de SPEAK_COOLDOWN segundos)
        lastTransferTime[pid] = currentTime

        -- Só fala se:
        --  - não há Hazmat
        --  - existe uma mensagem apropriada (bare hands / gloves holes)
        --  - e o cooldown anterior tinha expirado (allowedToSpeak == true)
        if not hasHazmat and speakMessage and allowedToSpeak then
            player:Say(speakMessage)
        end

        -- Aplicar infecção com base na chance calculada (Hazmat impede)
        if not hasHazmat and ZombRand(100) >= safeChance then
            player:getBodyDamage():setInfected(true)
        end
    end

    -- manter comportamento original
    old_perform(self)
end
