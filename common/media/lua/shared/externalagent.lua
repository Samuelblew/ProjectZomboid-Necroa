-- ResetAllMenus_Robust.lua

-- 1. Criamos uma "flag" de controle fora da função de evento.
--    Ela vai controlar se o reset já foi executado nesta sessão de jogo.
local jaResetouNestaSessao = false
local ControlledInitializer = require("ControlledInitializer")

-- A nossa função de reset continua a mesma
local function resetAllMenus()
    local ModState = require("ModState")
    local WorldDatabase = require("WorldDatabase")
    local savedState = ModState.load() or {}

    print("==============================================")
    print("PRIMEIRO UPDATE DETECTADO: RESETANDO TODOS OS MENUS...")

    -- Reseta o AbilitiesMenu (28 ícones)
    for i = 1, 28 do
        savedState["abilityIcon" .. i] = "media/textures/locker.png"
        ModState.save(savedState)
    end
    print(" - AbilitiesMenu resetado.")

    -- Reseta o InfectionMenu (20 ícones)
    for i = 1, 20 do
        savedState["infectionIcon" .. i] = "media/textures/locker.png"
        ModState.save(savedState)
    end
    print(" - InfectionMenu resetado.")

    -- Reseta o SymptomMenu (31 ícones)
    for i = 1, 31 do
        savedState["symptomIcon" .. i] = "media/textures/locker.png"
        ModState.save(savedState)
    end
    print(" - SymptomMenu resetado.")

    ModState.save(savedState)
    print("RESET AUTOMÁTICO CONCLUÍDO COM SUCESSO!")
    print("==============================================")

    -- Inicializa o banco de dados após o reset
    WorldDatabase.markAsInitialized()
    
    -- Tenta carregar ícones salvos para este mundo
    if WorldDatabase.loadSavedIcons() then
        print("Ícones salvos carregados do banco de dados para este mundo!")
    else
        print("Nenhum ícone salvo encontrado para este mundo.")
    end

    -- Após resetar e recarregar ícones do banco, rodar a inicialização controlada
    if ControlledInitializer and ControlledInitializer.run then
        print("[externalagent] Executando ControlledInitializer após WorldDatabase.loadSavedIcons()...")
        ControlledInitializer.run()
    end

    -- 3. MUITO IMPORTANTE: Mudamos a flag para 'true' no final.
    --    Isso impede que o código seja executado novamente.
    jaResetouNestaSessao = true
end

-- 2. Adicionamos a lógica ao OnPlayerUpdate
Events.OnPlayerUpdate.Add(function(player)
    -- Este 'if' só será verdadeiro na primeira vez que o evento rodar.
    -- Nas vezes seguintes, 'jaResetouNestaSessao' será 'true', e o código será ignorado.
    if not jaResetouNestaSessao then
        resetAllMenus()
    end
end)