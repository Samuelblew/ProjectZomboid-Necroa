-- WorldDatabaseAutoSave.lua
-- Sistema de auto-save que salva automaticamente ícones não-padrão no banco de dados
-- Funciona apenas após o externalagent.lua ter feito seu trabalho

local WorldDatabase = require("WorldDatabase")
local DraggableIconMenu = require("DraggableIcon_Menu")

local WorldDatabaseAutoSave = {}
local lastSaveTime = 0
local SAVE_INTERVAL = 2.0 -- Salva a cada 2 segundos
local saveTimer = 0

-- Função para salvar ícones não-padrão automaticamente
local function autoSaveNonDefaultIcons()
    if not WorldDatabase.isInitialized() then
        return -- Não salva se o banco não foi inicializado ainda
    end
    
    local currentTime = getTimestamp()
    if currentTime - lastSaveTime >= SAVE_INTERVAL then
        if WorldDatabase.saveNonDefaultIcons() then
            lastSaveTime = currentTime
            print("[WorldDatabaseAutoSave] Auto-save executado com sucesso")
        end
    end
end

-- Função para verificar se há mudanças nos ícones e salvar se necessário
local function checkAndSaveChanges()
    if not WorldDatabase.isInitialized() then
        return
    end
    
    -- Só salva se o menu estiver aberto (para evitar spam de logs)
    if DraggableIconMenu.isOpen() then
        autoSaveNonDefaultIcons()
    end
end

-- Evento que roda a cada frame para verificar mudanças
Events.OnTick.Add(function()
    saveTimer = saveTimer + 0.016 -- Assumindo ~60 FPS
    
    if saveTimer >= 1.0 then -- Verifica a cada segundo
        saveTimer = 0
        checkAndSaveChanges()
    end
end)

-- Função para forçar um save imediato
function WorldDatabaseAutoSave.forceSave()
    if WorldDatabase.isInitialized() then
        if WorldDatabase.saveNonDefaultIcons() then
            print("[WorldDatabaseAutoSave] Save forçado executado com sucesso")
            return true
        end
    else
        print("[WorldDatabaseAutoSave] ERRO: Banco não foi inicializado ainda!")
    end
    return false
end

-- Função para obter estatísticas do auto-save
function WorldDatabaseAutoSave.getStats()
    return {
        lastSaveTime = lastSaveTime,
        saveInterval = SAVE_INTERVAL,
        isInitialized = WorldDatabase.isInitialized(),
        currentWorldStats = WorldDatabase.getCurrentWorldStats()
    }
end

-- Função para alterar o intervalo de save
function WorldDatabaseAutoSave.setSaveInterval(interval)
    if interval > 0 then
        SAVE_INTERVAL = interval
        print("[WorldDatabaseAutoSave] Intervalo de save alterado para: " .. interval .. " segundos")
    end
end

return WorldDatabaseAutoSave
