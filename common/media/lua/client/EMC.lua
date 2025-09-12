local ModState = require("ModState")

local emt = {}
emt.lastIcon1 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon3 or "media/textures/locker.png"

    -- normaliza só por precaução (remove espaços acidentais)
    icon1 = tostring(icon1):gsub("%s+$", "")

    -- Só executa se mudou algum ícone
    if icon1 ~= emt.lastIcon1 then
        emt.lastIcon1 = icon1

        local optionspeed = getSandboxOptions():getOptionByName("ZombieLore.Speed")
  
        if icon1 == "media/textures/EMC.png" and optionspeed then
            optionspeed:setValue(2)
            print("EMC ON") 
        end

        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
