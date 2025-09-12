local ModState = require("ModState")

local ES = {}
ES.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon15  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= ES.lastIcon1 then
        ES.lastIcon1 = icon1

        local optionHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing")
        local optionSight = getSandboxOptions():getOptionByName("ZombieLore.Sight")
  
        if icon1 == "media/textures/ES.png" then
            optionSight:setValue(5)
            optionHearing:setValue(5)
            print("ESI ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)