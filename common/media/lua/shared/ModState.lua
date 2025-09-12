local ModState = {}

-- Um nome único para os dados do seu mod. Pense nisso como o "nome do arquivo" dentro do ModData.
local MOD_DATA_KEY = "SeuModInfectionMenuState" -- Use um nome que seja único para o seu mod!

-- Salva o estado.
-- O ModData salva os dados automaticamente quando o jogador salva o jogo.
-- Você só precisa manter a tabela de estado atualizada.
function ModState.save(state)
    -- Pega a tabela de dados do seu mod (ou cria uma nova se não existir)
    local data = ModData.getOrCreate(MOD_DATA_KEY)
    
    -- Limpa a tabela antiga para garantir que não sobrem dados velhos
    for k in pairs(data) do
        data[k] = nil
    end
    
    -- Copia os novos dados para a tabela do ModData
    for k, v in pairs(state) do
        data[k] = v
    end
end

-- Carrega o estado salvo.
-- O ModData já carregou os dados quando o mundo foi carregado.
-- Você só precisa pegar a tabela.
function ModState.load()
    -- Tenta pegar os dados salvos para a nossa chave.
    local savedData = ModData.get(MOD_DATA_KEY)
    
    -- Se não houver dados salvos (primeira vez no mundo), retorna uma tabela vazia.
    if not savedData then
        return {}
    end
    
    -- Retorna uma cópia para evitar modificar a tabela original do ModData acidentalmente
    local state = {}
    for k, v in pairs(savedData) do
        state[k] = v
    end

    return state
end

return ModState