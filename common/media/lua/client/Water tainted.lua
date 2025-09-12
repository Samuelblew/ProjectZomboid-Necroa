local ModState = require("ModState")

-- estado persistente para detectar mudanças (escopo de módulo)
local lastIcon18 = nil
local lastIcon19 = nil

-- verifica se o ícone 2 indica água contaminada
local function isWaterTainted(icon1, icon2)
    return icon2 == "media/textures/Water_Icon2.png"
end

-- verifica se o ícone 1 indica água contaminada
local function isWaterTaintedIcon1(icon1)
    return icon1 == "media/textures/Water_Icon.png"
end

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = tostring(savedState.infectionIcon18 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon2 = tostring(savedState.infectionIcon19 or "media/textures/locker.png"):gsub("%s+$", "")

    if icon1 ~= lastIcon18 or icon2 ~= lastIcon19 then
        lastIcon18 = icon1
        lastIcon19 = icon2

        if icon2 == "media/textures/Water_Icon2.png" then
            print("[Transmissao] water2 selecionado")
        elseif icon1 == "media/textures/Water_Icon.png" then
            print("[Transmissao] water selecionado")
        elseif icon1 == "media/textures/locker.png" and icon2 == "media/textures/locker.png" then
            print("[Transmissao] Nenhuma transmissão selecionada")
        else
            print("[Transmissao] Estado padrão mantido")
        end
    end
end

-- garante que o listener seja adicionado só uma vez
if not __transmission_listener_added then
    Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
    __transmission_listener_added = true
end

function ISDrinkFluidAction:start()
    -- atualizar referência do item no cliente
    if isClient() and self.item then
        self.item = self.character:getInventory():getItemById(self.item:getID())
    end

    -- verifica se o líquido no recipiente é contaminado (água contaminada ou veneno)
    local isTainted = false
    local container = self.item and self.item:getFluidContainer()
    if container and (container:contains(Fluid.TaintedWater) or container:contains(Fluid.Poison)) then
        isTainted = true
    end

    -- pega os ícones salvos (UI / estado do mod)
    local savedState = ModState.load() or {}
    local icon1 = tostring(savedState.infectionIcon18 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon2 = tostring(savedState.infectionIcon19 or "media/textures/locker.png"):gsub("%s+$", "")

    -- só infecta se o líquido estiver contaminado e o ícone estiver ativo
    if isTainted then
        if isWaterTainted(icon1, icon2) then
            local chance2 = ZombRandFloat(0, 1)
            if chance2 <= 0.80 then
                local body = self.character:getBodyDamage()
                if body and not body:isInfected() then
                    body:setInfected(true)
                end
                print("[Tracker] Personagem infectado via Icon2.")
            else
                print("[Tracker] Resistiu à infecção Icon2 (chance "..string.format("%.2f", chance2)..")")
            end
        elseif isWaterTaintedIcon1(icon1) then
            local chance1 = ZombRandFloat(0, 1)
            if chance1 <= 0.50 then
                local body = self.character:getBodyDamage()
                if body and not body:isInfected() then
                    body:setInfected(true)
                end
                print("[Tracker] Personagem infectado via Icon1.")
            else
                print("[Tracker] Resistiu à infecção Icon1 (chance "..string.format("%.2f", chance1)..")")
            end
        else
            print("[Tracker] Água contaminada, mas nenhum ícone ativo para transmissão.")
        end
    else
        print("[Tracker] Líquido não contaminado, sem infecção.")
    end

    -- lógica original do start() abaixo, com ajustes para sons, animações e eventos

    if self.item ~= nil and self.eatSound == "DrinkingFromMug" then
        local heat = (self.item:IsFood() or self.item:IsDrainable()) and self.item:getHeat() or 1.0
        if not (self.item:IsFood() or self.item:IsDrainable()) then
            heat = self.item:getItemHeat()
        end
        if heat > 1 then
            self.eatSound = "DrinkingFromHotTeaCup"
        end
    end

    if self.eatSound ~= '' then
        self.eatAudio = self.character:getEmitter():playSound(self.eatSound)
    end

    if self.item:getCustomMenuOption() then
        self.item:setJobType(self.item:getCustomMenuOption())
    else
        self.item:setJobDelta(0.0)
        self.item:setJobType(getText("ContextMenu_Drink"))
    end

    if self.item:getEatType() then
        self:setAnimVariable("FoodType", self.item:getEatType())
        if self.item:getEatType() == "Pot" then
            self:setOverrideHandModels(self.item, nil)
        end
    else
        self:setAnimVariable("FoodType", "bottle")
    end

    self:setActionAnim(CharacterActionAnims.Drink)
    self:setOverrideHandModels(nil, self.item)
    self.character:reportEvent("EventEating")
end
