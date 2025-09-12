local ModState = require("ModState")

local MT = {}
MT.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon11  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= MT.lastIcon1 then
        MT.lastIcon1 = icon1

        local optionStrength = getSandboxOptions():getOptionByName("ZombieLore.Strength")
  
        if icon1 == "media/textures/MT.png" and optionStrength then
            optionStrength:setValue(4)
            print("MT ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)