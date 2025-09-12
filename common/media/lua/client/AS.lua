local ModState = require("ModState")

local AS = {}
AS.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon14  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= AS.lastIcon1 then
        AS.lastIcon1 = icon1

        local optionHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing")
        local optionSight = getSandboxOptions():getOptionByName("ZombieLore.Sight")
  
        if icon1 == "media/textures/AS.png" then
            optionSight:setValue(1)
            optionHearing:setValue(1)
            print("AS ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)