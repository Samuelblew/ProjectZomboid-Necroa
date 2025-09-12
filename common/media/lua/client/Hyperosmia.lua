local ModState = require("ModState")

local Hyperosmia = {}
Hyperosmia.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon16  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= Hyperosmia.lastIcon1 then
        Hyperosmia.lastIcon1 = icon1

        local optionHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing")
        local optionSight = getSandboxOptions():getOptionByName("ZombieLore.Sight")
  
        if icon1 == "media/textures/Hyperosmia.png" then
            optionSight:setValue(4)
            optionHearing:setValue(4)
            print("Hyperosmia ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)