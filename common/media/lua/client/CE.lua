local ModState = require("ModState")

local CE = {}
CE.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon9  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= CE.lastIcon1 then
        CE.lastIcon1 = icon1

        local optionToughness = getSandboxOptions():getOptionByName("ZombieLore.Toughness")
  
        if icon1 == "media/textures/CE.png" and optionToughness then
            optionToughness:setValue(4)
            print("CE ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)