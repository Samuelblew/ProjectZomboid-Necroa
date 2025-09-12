-- WorldDatabaseExample.lua
-- Exemplo de como usar o sistema de banco de dados por mundo

local WorldDatabase = require("WorldDatabase")
local WorldDatabaseAutoSave = require("WorldDatabaseAutoSave")
local ModState = require("ModState")

local WorldDatabaseExample = {}

-- Função para demonstrar como salvar ícones manualmente
function WorldDatabaseExample.saveCurrentIcons()
    if not WorldDatabase.isInitialized() then
        print("[WorldDatabaseExample] ERRO: Banco não foi inicializado ainda!")
        return false
    end
    
    local result = WorldDatabase.saveNonDefaultIcons()
    if result then
        print("[WorldDatabaseExample] Ícones salvos manualmente com sucesso!")
    else
        print("[WorldDatabaseExample] Nenhum ícone não-padrão encontrado para salvar.")
    end
    return result
end

-- Função para demonstrar como carregar ícones salvos
function WorldDatabaseExample.loadSavedIcons()
    if not WorldDatabase.isInitialized() then
        print("[WorldDatabaseExample] ERRO: Banco não foi inicializado ainda!")
        return false
    end
    
    local result = WorldDatabase.loadSavedIcons()
    if result then
        print("[WorldDatabaseExample] Ícones carregados com sucesso!")
    else
        print("[WorldDatabaseExample] Nenhum ícone salvo encontrado para este mundo.")
    end
    return result
end

-- Função para demonstrar como obter estatísticas do mundo atual
function WorldDatabaseExample.showCurrentWorldStats()
    if not WorldDatabase.isInitialized() then
        print("[WorldDatabaseExample] ERRO: Banco não foi inicializado ainda!")
        return nil
    end
    
    local stats = WorldDatabase.getCurrentWorldStats()
    if stats then
        print("=== ESTATÍSTICAS DO MUNDO ATUAL ===")
        print("ID do Mundo: " .. stats.worldId)
        print("Última Atualização: " .. stats.lastUpdated)
        print("Ícones de Habilidades: " .. stats.abilitiesCount)
        print("Ícones de Infecção: " .. stats.infectionsCount)
        print("Ícones de Sintomas: " .. stats.symptomsCount)
        print("Total de Ícones: " .. stats.totalIcons)
        print("==================================")
        return stats
    else
        print("[WorldDatabaseExample] Nenhum dado encontrado para este mundo.")
        return nil
    end
end

-- Função para demonstrar como listar todos os mundos salvos
function WorldDatabaseExample.listAllSavedWorlds()
    local worlds = WorldDatabase.listSavedWorlds()
    
    if #worlds > 0 then
        print("=== MUNDOS COM DADOS SALVOS ===")
        for i, world in ipairs(worlds) do
            print(i .. ". " .. world.id)
            print("   - Última Atualização: " .. world.lastUpdated)
            print("   - Habilidades: " .. world.abilitiesCount)
            print("   - Infecções: " .. world.infectionsCount)
            print("   - Sintomas: " .. world.symptomsCount)
            print("   - Total: " .. (world.abilitiesCount + world.infectionsCount + world.symptomsCount))
        end
        print("===============================")
    else
        print("[WorldDatabaseExample] Nenhum mundo com dados salvos encontrado.")
    end
    
    return worlds
end

-- Função para demonstrar como limpar dados de um mundo específico
function WorldDatabaseExample.clearWorldData(worldId)
    if not worldId then
        print("[WorldDatabaseExample] ERRO: ID do mundo não fornecido!")
        return false
    end
    
    local result = WorldDatabase.clearWorldData(worldId)
    if result then
        print("[WorldDatabaseExample] Dados do mundo '" .. worldId .. "' limpos com sucesso!")
    else
        print("[WorldDatabaseExample] Nenhum dado encontrado para o mundo '" .. worldId .. "'")
    end
    return result
end

-- Função para demonstrar como alterar o intervalo de auto-save
function WorldDatabaseExample.setAutoSaveInterval(interval)
    if not interval or interval <= 0 then
        print("[WorldDatabaseExample] ERRO: Intervalo inválido!")
        return false
    end
    
    WorldDatabaseAutoSave.setSaveInterval(interval)
    print("[WorldDatabaseExample] Intervalo de auto-save alterado para: " .. interval .. " segundos")
    return true
end

-- Função para demonstrar como forçar um save imediato
function WorldDatabaseExample.forceAutoSave()
    local result = WorldDatabaseAutoSave.forceSave()
    if result then
        print("[WorldDatabaseExample] Auto-save forçado executado com sucesso!")
    else
        print("[WorldDatabaseExample] Falha ao executar auto-save forçado.")
    end
    return result
end

-- Função para demonstrar como obter estatísticas do auto-save
function WorldDatabaseExample.showAutoSaveStats()
    local stats = WorldDatabaseAutoSave.getStats()
    
    print("=== ESTATÍSTICAS DO AUTO-SAVE ===")
    print("Último Save: " .. stats.lastSaveTime)
    print("Intervalo de Save: " .. stats.saveInterval .. " segundos")
    print("Banco Inicializado: " .. (stats.isInitialized and "Sim" or "Não"))
    
    if stats.currentWorldStats then
        print("Mundo Atual: " .. stats.currentWorldStats.worldId)
        print("Total de Ícones: " .. stats.currentWorldStats.totalIcons)
    end
    print("=================================")
    
    return stats
end

-- Função para demonstrar como simular mudanças nos ícones
function WorldDatabaseExample.simulateIconChanges()
    if not WorldDatabase.isInitialized() then
        print("[WorldDatabaseExample] ERRO: Banco não foi inicializado ainda!")
        return false
    end
    
    local currentState = ModState.load() or {}
    
    -- Simula mudanças em alguns ícones
    currentState["abilityIcon1"] = "media/textures/HI.png"
    currentState["infectionIcon1"] = "media/textures/Bird_Icon.png"
    currentState["symptomIcon1"] = "media/textures/Cytopathic_Reanimation_Icon.png"
    
    ModState.save(currentState)
    print("[WorldDatabaseExample] Mudanças simuladas nos ícones!")
    print(" - Habilidade 1: HI.png")
    print(" - Infecção 1: Bird_Icon.png")
    print(" - Sintoma 1: Cytopathic_Reanimation_Icon.png")
    
    return true
end

return WorldDatabaseExample
