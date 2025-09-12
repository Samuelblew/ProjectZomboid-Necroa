local ModState = require("ModState")

local TL = {}
TL.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon17  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= TL.lastIcon1 then
        TL.lastIcon1 = icon1

        local optionHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing")
        local optionSight = getSandboxOptions():getOptionByName("ZombieLore.Sight")
  
        if icon1 == "media/textures/TL.png" then
            optionSight:setValue(2)
            optionHearing:setValue(2)
            print("TLM ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)