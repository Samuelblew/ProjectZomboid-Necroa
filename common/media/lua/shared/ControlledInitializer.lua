-- =================================================================
-- ControlledInitializer.lua
-- AKA "Gambiarra 2.0" (v1.1 - Com prints por ícone)
-- Autor: Gemini (comissionado pelo meu mano)
--
-- OBJETIVO:
-- 1. Roda DEPOIS que o banco de dados principal joga os dados no ModState.
-- 2. Identifica quais ícones de uma lista específica estão ativos.
-- 3. Reseta TODOS os ícones dessa lista para o estado inativo.
-- 4. Reativa os ícones que estavam ativos, mas na ORDEM CORRETA.
-- =================================================================

local ControlledInitializer = {}
local ModState = require("ModState")

-- =================================================================
-- CONFIGURAÇÃO DA SEQUÊNCIA
-- Essa é a sua lista. A ordem aqui é a ordem que o script vai seguir.
-- Se precisar mudar a ordem ou adicionar/remover ícones, é SÓ MEXER AQUI.
-- =================================================================
local ACTIVATION_SEQUENCE = {
    -- Estrutura: { id = ID_do_Icone, key = "chave_no_modstate", activeTexture = "caminho/da/textura/ativa.png" }

    -- 1º na sequência
    { id = 2,  key = "symptomIcon1",  activeTexture = "media/textures/Anaerobic_Resuscitation_Icon.png" },
    -- 2º na sequência
    { id = 3,  key = "symptomIcon3",  activeTexture = "media/textures/EMC.png" },
    -- 3º na sequência
    { id = 11, key = "symptomIcon11", activeTexture = "media/textures/MT.png" },
    -- 4º na sequência
    { id = 4,  key = "symptomIcon4",  activeTexture = "media/textures/PS.png" },
    -- 5º na sequência
    { id = 12, key = "symptomIcon12", activeTexture = "media/textures/AB.png" },
    -- 6º na sequência
    { id = 9,  key = "symptomIcon9",  activeTexture = "media/textures/CE.png" },
    -- 7º na sequência
    { id = 10, key = "symptomIcon10", activeTexture = "media/textures/BD.png" },
    -- 8º na sequência
    { id = 15, key = "symptomIcon15", activeTexture = "media/textures/ES.png" },
    -- 9º na sequência
    { id = 16, key = "symptomIcon16", activeTexture = "media/textures/Hyperosmia.png" },
    -- 10º na sequência
    { id = 17, key = "symptomIcon17", activeTexture = "media/textures/TL.png" },
    -- 11º na sequência
    { id = 14, key = "symptomIcon14", activeTexture = "media/textures/AS.png" },
}

local LOCKER_TEXTURE = "media/textures/locker.png"

-- =================================================================
-- A FUNÇÃO PRINCIPAL
-- =================================================================
function ControlledInitializer.run()
    print("[ControlledInitializer] Iniciando sequência de inicialização controlada...")

    -- PASSO 1: Carregar o estado atual (e bagunçado) do ModState
    local savedState = ModState.load() or {}

    -- PASSO 2: Fazer a lista dos ícones da NOSSA SEQUÊNCIA que estão ativos
    local iconsParaReativar = {}
    for _, node in ipairs(ACTIVATION_SEQUENCE) do
        local currentTexture = savedState[node.key]
        if currentTexture and currentTexture ~= LOCKER_TEXTURE then
            print("[ControlledInitializer] Ícone encontrado para reativar: " .. node.key)
            table.insert(iconsParaReativar, node)
        end
    end

    if #iconsParaReativar == 0 then
        print("[ControlledInitializer] Nenhum ícone da sequência estava ativo. Nada a fazer.")
        return
    end

    -- PASSO 3: Reset Cirúrgico - Desativar apenas os ícones que vamos reativar
    print("[ControlledInitializer] Resetando ícones da sequência para o estado 'locker'...")
    for _, node in ipairs(iconsParaReativar) do
        savedState[node.key] = LOCKER_TEXTURE
    end
    ModState.save(savedState)


    -- PASSO 4: Reativar os ícones na ordem correta da sequência
    print("[ControlledInitializer] Reativando ícones na ordem correta...")
    for _, nodeDaSequencia in ipairs(ACTIVATION_SEQUENCE) do
        for _, nodeParaReativar in ipairs(iconsParaReativar) do
            if nodeDaSequencia.id == nodeParaReativar.id then
                -- É esse! Ativa ele no ModState
                savedState[nodeDaSequencia.key] = nodeDaSequencia.activeTexture

                -- <<< MUDANÇA AQUI: Printa a confirmação de inserção individual >>>
                print("[ControlledInitializer] -> (" .. #iconsParaReativar .. " ativos) Inserido: " .. nodeDaSequencia.key)

                break
            end
        end
    end

    -- PASSO 5: Salvar o estado final e organizado no ModState
    print("[ControlledInitializer] Salvando estado final e organizado. Sequência concluída!")
    ModState.save(savedState)
end

return ControlledInitializer
