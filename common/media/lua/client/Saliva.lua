local ModState = require("ModState")

SprintersNights = SprintersNights or {}
SprintersNights.lastIcon1 = nil
SprintersNights.lastIcon2 = nil

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.infectionIcon15 or "media/textures/locker.png"
    local icon2 = savedState.infectionIcon16 or "media/textures/locker.png"

    -- Só aplica se mudou algo
    if icon1 ~= SprintersNights.lastIcon1 or icon2 ~= SprintersNights.lastIcon2 then
        SprintersNights.lastIcon1 = icon1
        SprintersNights.lastIcon2 = icon2

        local option = getSandboxOptions():getOptionByName("ZombieLore.Transmission")
        if not option then return end

        if icon2 == "media/textures/Saliva_Icon2.png" then
            print("[Transmissao] Blood and Saliva selected")
            option:setValue(1)
        elseif icon1 == "media/textures/Saliva_Icon.png" then
            print("[Transmissao] Saliva selected")
            option:setValue(2)
        elseif icon1 == "media/textures/locker.png" and icon2 == "media/textures/locker.png" then
            print("[Transmissao] None selected")
            option:setValue(4)
        else
            print("[Transmissao] Padrão mantida.")
        end

        -- Força aplicar no mundo
        getSandboxOptions():sendToServer()
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)
