-- Exemplo de como usar o sistema de refresh do ModState
-- Este arquivo demonstra como atualizar o ModState externamente e forçar o refresh dos menus

local DraggableIconMenu = require("DraggableIcon_Menu")
local ModState = require("ModState")

-- Função para demonstrar como atualizar ícones externamente
local function updateAbilityIcon(iconNumber, newTexture)
    local currentState = ModState.load() or {}
    currentState["abilityIcon" .. iconNumber] = newTexture
    ModState.save(currentState)
    
    -- Se o menu estiver aberto, força o refresh
    if DraggableIconMenu.isOpen() then
        DraggableIconMenu.refreshAllPanels()
    end
end

-- Função para demonstrar como atualizar ícones de infecção externamente
local function updateInfectionIcon(iconNumber, newTexture)
    local currentState = ModState.load() or {}
    currentState["infectionIcon" .. iconNumber] = newTexture
    ModState.save(currentState)
    
    -- Se o menu estiver aberto, força o refresh
    if DraggableIconMenu.isOpen() then
        DraggableIconMenu.refreshAllPanels()
    end
end

-- Função para demonstrar como atualizar ícones de sintomas externamente
local function updateSymptomIcon(iconNumber, newTexture)
    local currentState = ModState.load() or {}
    currentState["symptomIcon" .. iconNumber] = newTexture
    ModState.save(currentState)
    
    -- Se o menu estiver aberto, força o refresh
    if DraggableIconMenu.isOpen() then
        DraggableIconMenu.refreshAllPanels()
    end
end

-- Exemplo de uso:
-- updateAbilityIcon(1, "media/textures/HI.png")
-- updateInfectionIcon(1, "media/textures/Bird_Icon.png")
-- updateSymptomIcon(1, "media/textures/Cytopathic_Reanimation_Icon.png")

-- Exportar as funções para uso em outros arquivos
local ModStateRefreshExample = {
    updateAbilityIcon = updateAbilityIcon,
    updateInfectionIcon = updateInfectionIcon,
    updateSymptomIcon = updateSymptomIcon
}

return ModStateRefreshExample
