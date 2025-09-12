local ModState = require("ModState")

AirINF = AirINF or {}
AirINF.lastIcon1 = nil
AirINF.lastIcon2 = nil
AirINF.lastIcon3 = nil
AirINF.corpseInfectionEnabled = false -- Define um estado inicial seguro

local function atualizarTransmissaoComBaseNosIcones(player)
    if not player then return end

    local savedState = ModState.load() or {}
    local icon1 = savedState.infectionIcon11 or "media/textures/locker.png"
    local icon2 = savedState.infectionIcon12 or "media/textures/locker.png"
    local icon3 = savedState.infectionIcon13 or "media/textures/locker.png"

    if icon1 ~= AirINF.lastIcon1 or icon2 ~= AirINF.lastIcon2 or icon3 ~= AirINF.lastIcon3 then
        AirINF.lastIcon1 = icon1
        AirINF.lastIcon2 = icon2
        AirINF.lastIcon3 = icon3

        if icon3 == "media/textures/Air_Icon3.png" then
            print("[Transmissao] air3 selected. Infecção por Cadáveres ATIVADA.")
            -- LIGA o interruptor da infecção por cadáveres
            AirINF.corpseInfectionEnabled = true

            -- (Opcional) Adiciona o trait Susceptible se ainda não tiver
            if not player:HasTrait("Susceptible") then
                player:getTraits():add("Susceptible")
            end
            
        elseif icon2 == "media/textures/Air_Icon2.png" then
            print("[Transmissao] air2 selected. Infecção por Cadáveres DESATIVADA.")
            -- DESLIGA o interruptor
            AirINF.corpseInfectionEnabled = false

            -- (Opcional) Adiciona o trait Susceptible se ainda não tiver
            if not player:HasTrait("Susceptible") then
                player:getTraits():add("Susceptible")
            end

        elseif icon1 == "media/textures/Air_Icon.png" then
            print("[Transmissao] air1 selected. Infecção por Cadáveres DESATIVADA.")
            -- DESLIGA o interruptor
            AirINF.corpseInfectionEnabled = false

            -- Adiciona a trait APENAS se o jogador ainda não a tiver
            if not player:HasTrait("Susceptible") then
                player:getTraits():add("Susceptible")
            end

        elseif icon1 == "media/textures/locker.png" and icon2 == "media/textures/locker.png" and icon3 == "media/textures/locker.png" then
            print("[Transmissao] None air selected. Removendo Trait 'Susceptible'. Infecção por Cadáveres DESATIVADA.")
            -- DESLIGA o interruptor
            AirINF.corpseInfectionEnabled = false

            -- Remove a trait APENAS se o jogador a possuir
            if player:HasTrait("Susceptible") then
                player:getTraits():remove("Susceptible")
            end
        end
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)