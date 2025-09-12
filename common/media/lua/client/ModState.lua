local ModState = {}

-- Um nome único para os dados do seu mod. Pense nisso como o "nome do arquivo" dentro do ModData.
local MOD_DATA_KEY = "SeuModInfectionMenuState" -- Use um nome que seja único para o seu mod!
local WORLD_ID_KEY = "SusceptibleModWorldID" -- Chave para armazenar o ID único do mundo

-- Flag para controlar print único por mundo
local hasPrintedLoad = false
local lastPrintedWorldID = nil

-- Gera um ID único e permanente para o mundo atual baseado apenas no nome do mundo
local function generateWorldID()
    local worldName = getWorld():getWorld() or "UnknownWorld"
    
    -- Cria um hash simples e estável baseado no nome do mundo
    local hash = 0
    for i = 1, #worldName do
        local char = string.byte(worldName, i)
        hash = hash + char * (i * 31)
    end
    
    -- Gera ID único baseado no hash do nome do mundo
    local worldID = string.format("%s_%d", worldName, math.abs(hash))
    return worldID
end

-- Verifica se o mundo mudou e retorna informações sobre a mudança
function ModState.checkWorldChange()
    local currentWorldID = generateWorldID()
    local savedWorldID = ModData.get(WORLD_ID_KEY)
    
    if not savedWorldID then
        -- Primeira vez no mundo ou mundo novo
        ModData.getOrCreate(WORLD_ID_KEY)
        ModData.get(WORLD_ID_KEY).worldID = currentWorldID
        print("[SusceptibleMod] 🌍 NOVO MUNDO DETECTADO! ID: " .. currentWorldID)
        return true, "new_world", currentWorldID
    elseif savedWorldID.worldID ~= currentWorldID then
        -- Mundo diferente detectado
        local oldID = savedWorldID.worldID
        savedWorldID.worldID = currentWorldID
        print("[SusceptibleMod] 🔄 MUNDO MUDOU! Anterior: " .. oldID .. " | Atual: " .. currentWorldID)
        return true, "world_changed", currentWorldID, oldID
    else
        -- Mesmo mundo
        return false, "same_world", currentWorldID
    end
end

-- Retorna o ID do mundo atual
function ModState.getCurrentWorldID()
    local savedWorldID = ModData.get(WORLD_ID_KEY)
    if savedWorldID and savedWorldID.worldID then
        return savedWorldID.worldID
    end
    return generateWorldID()
end

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
    -- Verifica se o mundo mudou antes de carregar os dados
    local worldChanged, changeType, currentWorldID, oldWorldID = ModState.checkWorldChange()
    
    -- Print apenas uma vez por mundo
    if not hasPrintedLoad or lastPrintedWorldID ~= currentWorldID then
        print("[SusceptibleMod] 🔄 MUNDO CARREGADO! ID: " .. currentWorldID .. " | Mudou: " .. tostring(worldChanged))
        hasPrintedLoad = true
        lastPrintedWorldID = currentWorldID
    end
    
    -- Tenta pegar os dados salvos para a nossa chave.
    local savedData = ModData.get(MOD_DATA_KEY)
    
    -- Se não houver dados salvos (primeira vez no mundo), retorna uma tabela vazia.
    if not savedData then
        return {}
    end
    
    -- Se o mundo mudou, limpa os dados antigos e retorna tabela vazia
    if worldChanged then
        print("[SusceptibleMod] 🧹 Mundo mudou - limpando dados antigos")
        return {}
    end
    
    -- Retorna uma cópia para evitar modificar a tabela original do ModData acidentalmente
    local state = {}
    for k, v in pairs(savedData) do
        state[k] = v
    end

    return state
end

-- Função para mostrar informações do mundo (pode ser chamada via debug ou eventos)
function ModState.showWorldInfo()
    local currentWorldID = ModState.getCurrentWorldID()
    print("[SusceptibleMod] 🌍 ID do Mundo Atual: " .. currentWorldID)
    
    local savedWorldID = ModData.get(WORLD_ID_KEY)
    if savedWorldID and savedWorldID.worldID then
        print("[SusceptibleMod] 💾 ID Salvo: " .. savedWorldID.worldID)
    else
        print("[SusceptibleMod] 💾 Nenhum ID salvo encontrado")
    end
    
    local worldName = getWorld():getWorld() or "UnknownWorld"
    print("[SusceptibleMod] 📝 Nome do Mundo: " .. worldName)
    
    local worldChanged, changeType = ModState.checkWorldChange()
    print("[SusceptibleMod] 🔄 Mundo Mudou: " .. tostring(worldChanged) .. " | Tipo: " .. tostring(changeType))
end

-- Evento para mostrar info quando o mundo carrega (debug)
local function onWorldLoaded()
    -- Pequeno delay para garantir que tudo esteja carregado
    local function delayedShow()
        ModState.showWorldInfo()
    end
    
    -- Executa após 2 segundos
    local timer = 0
    local function onUpdate()
        timer = timer + 1
        if timer >= 120 then -- ~2 segundos a 60fps
            delayedShow()
            Events.OnTick.Remove(onUpdate)
        end
    end
    Events.OnTick.Add(onUpdate)
end

-- Registra o evento para mostrar info quando o mundo carrega
Events.OnGameStart.Add(onWorldLoaded)

return ModState