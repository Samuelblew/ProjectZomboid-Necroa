require "TimedActions/ISBaseTimedAction"
require "TimedActions/ISTakeWaterAction"

local ModState = require("ModState")

-- Armazena a função original
local originalPerform = ISTakeWaterAction.perform

-- Verifica se a água deve ser considerada contaminada
local function shouldTaintContainer(object)
    if not object then return false end

    local spriteName = object:getSprite() and object:getSprite():getName()

    -- Lista de sprites que NÃO devem contaminar (exceções)
    local safeSprites = {
        ["location_business_office_generic_01_49"] = true,
        ["carpentry_02_122"] = true,
        ["carpentry_02_124"] = true,
        ["carpentry_02_54"]  = true,
        ["carpentry_02_120"] = true,
    }

    if safeSprites[spriteName] then
        return false
    end

    -- Exceção: fontes externas (como casas com água encanada)
    if object.getUsesExternalWaterSource and object:getUsesExternalWaterSource() then
        return false
    end

    return true
end

-- Verifica se o ícone 2 indica água contaminada
local function isWaterTainted(icon1, icon2)
    return icon2 == "media/textures/Water_Icon2.png"
end

-- Verifica se o ícone 1 indica água contaminada
local function isWaterTaintedIcon1(icon1)
    return icon1 == "media/textures/Water_Icon.png"
end

-- Sobrescreve a função perform
function ISTakeWaterAction:perform()
    -- Chama a função original
    originalPerform(self)

    -- Verifica se é uma ação de beber diretamente (sem item)
    if not self.item then
        local player = self.character
        local spriteName = self.waterObject:getSprite() and self.waterObject:getSprite():getName() or "desconhecido"
        print("Jogador " .. player:getUsername() .. " bebeu água diretamente de um objeto do mundo! (Sprite: " .. spriteName .. ")")

        -- Carrega ícones do ModState
        local savedState = ModState.load() or {}
        local icon1 = tostring(savedState.infectionIcon18 or "media/textures/locker.png"):gsub("%s+$", "")
        local icon2 = tostring(savedState.infectionIcon19 or "media/textures/locker.png"):gsub("%s+$", "")

        -- Verifica se a fonte de água deve ser considerada contaminada
        if shouldTaintContainer(self.waterObject) then
            -- Aplica infecção com base nos ícones
            if isWaterTainted(icon1, icon2) then
                local chance2 = ZombRandFloat(0, 1)
                if chance2 <= 0.80 then
                    local body = player:getBodyDamage()
                    if body and not body:isInfected() then
                        body:setInfected(true)
                    end
                    print("[Tracker] Personagem infectado via Icon2 (beber direto).")
                else
                    print("[Tracker] Resistiu à infecção Icon2 (chance "..string.format("%.2f", chance2)..")")
                end
            elseif isWaterTaintedIcon1(icon1) then
                local chance1 = ZombRandFloat(0, 1)
                if chance1 <= 0.50 then
                    local body = player:getBodyDamage()
                    if body and not body:isInfected() then
                        body:setInfected(true)
                    end
                    print("[Tracker] Personagem infectado via Icon1 (beber direto).")
                else
                    print("[Tracker] Resistiu à infecção Icon1 (chance "..string.format("%.2f", chance1)..")")
                end
            else
                print("[Tracker] Nenhum ícone ativo para infecção ao beber direto.")
            end
        else
            print("[Tracker] Fonte de água segura detectada — infecção ignorada.")
        end
    end
end
