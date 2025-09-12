local ModState = require("ModState")

-- Configurações internas
local CONFIG = {
    RandomMode = false,     -- Se usa tempo randômico
    MinRezTime = 12,        -- Mínimo em horas para levantar
    MaxRezTime = 12,        -- Máximo em horas para levantar
    RezSpeed = 6            -- Tempo fixo em horas (se RandomMode = false)
}

-- Estado dos ícones
local ABIL = {}
ABIL.lastIcon13 = nil
ABIL.lastIcon14 = nil
ABIL.lastIcon15 = nil
ABIL.lastIcon16 = nil
ABIL.lastIcon17 = nil
ABIL.lastIcon18 = nil

-- Atualiza estado dos ícones
local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}

    local icon13 = tostring(savedState.abilityIcon13 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon14 = tostring(savedState.abilityIcon14 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon15 = tostring(savedState.abilityIcon15 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon16 = tostring(savedState.abilityIcon16 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon17 = tostring(savedState.abilityIcon17 or "media/textures/locker.png"):gsub("%s+$", "")
    local icon18 = tostring(savedState.abilityIcon18 or "media/textures/locker.png"):gsub("%s+$", "")

    if icon13 ~= ABIL.lastIcon13 then
        ABIL.lastIcon13 = icon13
        if icon13 == "media/textures/RA.png" then
            print("RA Icon13 ON")
        end
    end

    if icon14 ~= ABIL.lastIcon14 then
        ABIL.lastIcon14 = icon14
        if icon14 == "media/textures/AP.png" then
            print("AP Icon14 ON")
        end
    end

    if icon15 ~= ABIL.lastIcon15 then
        ABIL.lastIcon15 = icon15
        if icon15 == "media/textures/LN.png" then
            print("LN Icon15 ON")
        end
    end

    if icon16 ~= ABIL.lastIcon16 then
        ABIL.lastIcon16 = icon16
        if icon16 == "media/textures/RB.png" then
            print("RB Icon16 ON")
        end
    end

    if icon17 ~= ABIL.lastIcon17 then
        ABIL.lastIcon17 = icon17
        if icon17 == "media/textures/ED.png" then
            print("ED Icon17 ON")
        end
    end

    if icon18 ~= ABIL.lastIcon18 then
        ABIL.lastIcon18 = icon18
        if icon18 == "media/textures/CM.png" then
            print("CM Icon18 ON")
        end
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)

-- Função que calcula chance baseada nos ícones
local function calcularChanceReanimacao()
    -- Se o ícone 13 não estiver ligado, chance = 0
    if ABIL.lastIcon13 ~= "media/textures/RA.png" then
        return 0
    end

    local chance = 0
    if ABIL.lastIcon13 == "media/textures/RA.png" then chance = chance + 16 end
    if ABIL.lastIcon14 == "media/textures/AP.png" then chance = chance + 16 end
    if ABIL.lastIcon15 == "media/textures/LN.png" then chance = chance + 16 end
    if ABIL.lastIcon16 == "media/textures/RB.png" then chance = chance + 16 end
    if ABIL.lastIcon17 == "media/textures/ED.png" then chance = chance + 16 end
    if ABIL.lastIcon18 == "media/textures/CM.png" then chance = chance + 16 end

    if chance > 100 then chance = 100 end
    return chance
end

-- Evento de spawn de corpo
local function OnDeadBodySpawn(body)
    if instanceof(body, "IsoDeadBody") then
        local time = getGameTime()
        local chance = calcularChanceReanimacao()

        -- Testa a chance
        if (ZombRand(100) + 1) > chance then
            return
        end

        -- Define tempo de reanimação
        local rezTime
        if CONFIG.RandomMode then
            rezTime = ZombRand(CONFIG.MinRezTime, CONFIG.MaxRezTime + 1)
        else
            rezTime = CONFIG.RezSpeed
        end

        body:setReanimateTime(time:getWorldAgeHours() + rezTime)
    end
end

Events.OnDeadBodySpawn.Add(OnDeadBodySpawn)
