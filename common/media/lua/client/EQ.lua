local ModState = require("ModState")

local EQ = {}
EQ.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.abilityIcon6  or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= EQ.lastIcon1 then
        EQ.lastIcon1 = icon1

        local optionspeed = getSandboxOptions():getOptionByName("ZombieLore.Speed")
  
        if icon1 == "media/textures/EQ.png" and optionspeed then
            optionspeed:setValue(1)
            print("EQ ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
