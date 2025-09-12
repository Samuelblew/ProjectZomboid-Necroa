local ModState = require("ModState")

local BD = {}
BD.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon10  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= BD.lastIcon1 then
        BD.lastIcon1 = icon1

        local optionToughness = getSandboxOptions():getOptionByName("ZombieLore.Toughness")
  
        if icon1 == "media/textures/BD.png" and optionToughness then
            optionToughness:setValue(1)
            print("BD ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)