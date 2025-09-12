local ModState = require("ModState")

local AB = {}
AB.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon12  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= AB.lastIcon1 then
        AB.lastIcon1 = icon1

        local optionStrength = getSandboxOptions():getOptionByName("ZombieLore.Strength")
  
        if icon1 == "media/textures/AB.png" and optionStrength then
            optionStrength:setValue(1)
            print("AB ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)