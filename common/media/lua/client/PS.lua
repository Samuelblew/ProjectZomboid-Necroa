local ModState = require("ModState")

local ps = {}
ps.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon4  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= ps.lastIcon1 then
        ps.lastIcon1 = icon1

        local optionStrength = getSandboxOptions():getOptionByName("ZombieLore.Strength")
  
        if icon1 == "media/textures/PS.png" and optionStrength then
            optionStrength:setValue(2)
            print("PS ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
