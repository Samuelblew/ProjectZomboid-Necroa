local ModState = require("ModState")

local DC = {}
DC.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon5  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= DC.lastIcon1 then
        DC.lastIcon1 = icon1

        local optionToughness = getSandboxOptions():getOptionByName("ZombieLore.Toughness")
  
        if icon1 == "media/textures/DC.png" and optionToughness then
            optionToughness:setValue(2)
            print("DC ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
