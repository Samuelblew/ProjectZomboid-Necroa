-- WorldDatabase.lua
-- Sistema de banco de dados que armazena informações específicas de cada mundo
-- Só armazena ícones que não sejam o padrão "locker.png"
-- Funciona após o reset do externalagent.lua

local WorldDatabase = {}
local ModState = require("ModState")

-- Chave única para o banco de dados por mundo
local WORLD_DB_KEY = "WorldSpecificIconDatabase"

-- Flag para controlar se o banco já foi inicializado após o reset
local databaseInitialized = false

-- Função para obter um ID único do mundo atual
local function getWorldId()
    -- Usa o nome do mundo + seed para criar um ID único
    local worldName = getWorld():getWorld()
    local seed = getWorld():getGameMode()
    return worldName .. "_" .. (seed or "default")
end

-- Função para inicializar o banco de dados
local function initializeDatabase()
    if databaseInitialized then
        return
    end
    
    local worldId = getWorldId()
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    
    -- Se não existe entrada para este mundo, cria uma nova
    if not dbData[worldId] then
        dbData[worldId] = {
            abilities = {},
            infections = {},
            symptoms = {},
            lastUpdated = 0
        }
        print("[WorldDatabase] Novo banco de dados criado para o mundo: " .. worldId)
    else
        print("[WorldDatabase] Banco de dados carregado para o mundo: " .. worldId)
    end
    
    databaseInitialized = true
end

-- Função para salvar ícones não-padrão no banco de dados
function WorldDatabase.saveNonDefaultIcons()
    if not databaseInitialized then
        print("[WorldDatabase] ERRO: Banco não foi inicializado ainda!")
        return false
    end
    
    local worldId = getWorldId()
    local currentState = ModState.load() or {}
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    
    -- Garante que existe entrada para este mundo
    if not dbData[worldId] then
        dbData[worldId] = {
            abilities = {},
            infections = {},
            symptoms = {},
            lastUpdated = 0
        }
    end
    
    local hasChanges = false
    
    -- Salva ícones de habilidades não-padrão
    for i = 1, 28 do
        local iconKey = "abilityIcon" .. i
        local iconPath = currentState[iconKey]
        if iconPath and iconPath ~= "media/textures/locker.png" then
            dbData[worldId].abilities[i] = iconPath
            hasChanges = true
        else
            -- Remove se for padrão
            dbData[worldId].abilities[i] = nil
        end
    end
    
    -- Salva ícones de infecção não-padrão
    for i = 1, 20 do
        local iconKey = "infectionIcon" .. i
        local iconPath = currentState[iconKey]
        if iconPath and iconPath ~= "media/textures/locker.png" then
            dbData[worldId].infections[i] = iconPath
            hasChanges = true
        else
            -- Remove se for padrão
            dbData[worldId].infections[i] = nil
        end
    end
    
    -- Salva ícones de sintomas não-padrão
    for i = 1, 31 do
        local iconKey = "symptomIcon" .. i
        local iconPath = currentState[iconKey]
        if iconPath and iconPath ~= "media/textures/locker.png" then
            dbData[worldId].symptoms[i] = iconPath
            hasChanges = true
        else
            -- Remove se for padrão
            dbData[worldId].symptoms[i] = nil
        end
    end
    
    if hasChanges then
        dbData[worldId].lastUpdated = getTimestamp()
        print("[WorldDatabase] Ícones não-padrão salvos para o mundo: " .. worldId)
        return true
    end
    
    return false
end

-- Função para carregar ícones salvos do banco de dados
function WorldDatabase.loadSavedIcons()
    if not databaseInitialized then
        print("[WorldDatabase] ERRO: Banco não foi inicializado ainda!")
        return false
    end
    
    local worldId = getWorldId()
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    
    if not dbData[worldId] then
        print("[WorldDatabase] Nenhum dado salvo encontrado para o mundo: " .. worldId)
        return false
    end
    
    local currentState = ModState.load() or {}
    local hasChanges = false
    
    -- Carrega ícones de habilidades salvos
    for i, iconPath in pairs(dbData[worldId].abilities) do
        local iconKey = "abilityIcon" .. i
        if currentState[iconKey] ~= iconPath then
            currentState[iconKey] = iconPath
            hasChanges = true
        end
    end
    
    -- Carrega ícones de infecção salvos
    for i, iconPath in pairs(dbData[worldId].infections) do
        local iconKey = "infectionIcon" .. i
        if currentState[iconKey] ~= iconPath then
            currentState[iconKey] = iconPath
            hasChanges = true
        end
    end
    
    -- Carrega ícones de sintomas salvos
    for i, iconPath in pairs(dbData[worldId].symptoms) do
        local iconKey = "symptomIcon" .. i
        if currentState[iconKey] ~= iconPath then
            currentState[iconKey] = iconPath
            hasChanges = true
        end
    end
    
    if hasChanges then
        ModState.save(currentState)
        print("[WorldDatabase] Ícones carregados do banco para o mundo: " .. worldId)
        return true
    end
    
    return false
end

-- Função para limpar dados de um mundo específico
function WorldDatabase.clearWorldData(worldId)
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    if dbData[worldId] then
        dbData[worldId] = nil
        print("[WorldDatabase] Dados limpos para o mundo: " .. worldId)
        return true
    end
    return false
end

-- Função para listar todos os mundos com dados salvos
function WorldDatabase.listSavedWorlds()
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    local worlds = {}
    
    for worldId, data in pairs(dbData) do
        if type(data) == "table" then
            table.insert(worlds, {
                id = worldId,
                lastUpdated = data.lastUpdated or 0,
                abilitiesCount = data.abilities and #data.abilities or 0,
                infectionsCount = data.infections and #data.infections or 0,
                symptomsCount = data.symptoms and #data.symptoms or 0
            })
        end
    end
    
    return worlds
end

-- Função para obter estatísticas do mundo atual
function WorldDatabase.getCurrentWorldStats()
    if not databaseInitialized then
        return nil
    end
    
    local worldId = getWorldId()
    local dbData = ModData.getOrCreate(WORLD_DB_KEY)
    
    if not dbData[worldId] then
        return nil
    end
    
    local data = dbData[worldId]
    return {
        worldId = worldId,
        lastUpdated = data.lastUpdated or 0,
        abilitiesCount = data.abilities and #data.abilities or 0,
        infectionsCount = data.infections and #data.infections or 0,
        symptomsCount = data.symptoms and #data.symptoms or 0,
        totalIcons = (data.abilities and #data.abilities or 0) + 
                    (data.infections and #data.infections or 0) + 
                    (data.symptoms and #data.symptoms or 0)
    }
end

-- Função para marcar o banco como inicializado (chamada pelo externalagent)
function WorldDatabase.markAsInitialized()
    databaseInitialized = true
    initializeDatabase()
    print("[WorldDatabase] Banco marcado como inicializado")
end

-- Função para verificar se o banco está inicializado
function WorldDatabase.isInitialized()
    return databaseInitialized
end

return WorldDatabase
