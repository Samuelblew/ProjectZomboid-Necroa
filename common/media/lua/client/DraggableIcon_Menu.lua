local config = require("DraggableIcon_Options")
local InfectionMenu = require("InfectionMenu") -- painel modular de infecção
local SymptomMenu   = require("SymptomMenu")   -- painel modular de sintomas
local AbilitiesMenu = require("AbilitiesMenu") -- painel modular de habilidades

local DraggableIconMenu = {}
local window = nil
local dragging = false
local grabOffsetX, grabOffsetY = 0, 0
local dragZoneHeight = 20 -- altura da barra de arrastar
local refreshTimer = 0
local REFRESH_INTERVAL = 1.0 -- Refresh every 1 second

-- Widgets que alternaremos entre menus
local mainLabel
local infectionPanel -- painel modular
local symptomPanel   -- painel modular
local abilitiesPanel -- painel modular
local closeButton
local infectionButton
local symptomsButton
local abilitiesButton

-- Helper para checar se mouse está sobre um elemento UI
local function isMouseOverElement(element, x, y)
    if not element then return false end
    local ex, ey = element:getX(), element:getY()
    local ew, eh = element:getWidth(), element:getHeight()
    return x >= ex and x <= ex + ew and y >= ey and y <= ey + eh
end

function DraggableIconMenu.showMenu()
    if window then return end

    local width  = config.MenuWidth  or 800
    local height = config.MenuHeight or 600
    local screenW, screenH = getCore():getScreenWidth(), getCore():getScreenHeight()
    local x = (screenW - width) / 2
    local y = (screenH - height) / 2

    window = ISPanel:new(x, y, width, height)

    ------------------------------------------------------------------
    -- Drag handling
    ------------------------------------------------------------------
    function window:onMouseDown(mx, my)
        local overLabel      = isMouseOverElement(mainLabel, mx, my) or
                               (infectionPanel and infectionPanel:isVisible() and isMouseOverElement(infectionPanel, mx, my)) or
                               (symptomPanel and symptomPanel:isVisible() and isMouseOverElement(symptomPanel, mx, my)) or
                               (abilitiesPanel and abilitiesPanel:isVisible() and isMouseOverElement(abilitiesPanel, mx, my))
        local overClose      = isMouseOverElement(closeButton, mx, my)
        local overInfection  = isMouseOverElement(infectionButton, mx, my)
        local overSymptoms   = isMouseOverElement(symptomsButton, mx, my)
        local overAbilities  = isMouseOverElement(abilitiesButton, mx, my)

        if my <= dragZoneHeight and not overLabel and not overClose and not overInfection and not overSymptoms and not overAbilities then
            dragging     = true
            grabOffsetX  = mx
            grabOffsetY  = my
            self:setCapture(true)
            return true
        end
        return false
    end

    function window:onMouseUp(mx, my)
        dragging = false
        self:setCapture(false)
        return true
    end

    function window:onMouseMove(dx, dy)
        if dragging then
            local mouseX, mouseY = getMouseX(), getMouseY()
            self:setX(mouseX - grabOffsetX)
            self:setY(mouseY - grabOffsetY)
            return true
        end
        return false
    end

    -- Update function to refresh panels periodically
    function window:update()
        refreshTimer = refreshTimer + 0.016 -- Assuming ~60 FPS
        if refreshTimer >= REFRESH_INTERVAL then
            refreshTimer = 0
            
            -- Refresh all panels if they exist and have the refresh function
            if infectionPanel and infectionPanel.refreshFromModState then
                infectionPanel:refreshFromModState()
            end
            if symptomPanel and symptomPanel.refreshFromModState then
                symptomPanel:refreshFromModState()
            end
            if abilitiesPanel and abilitiesPanel.refreshFromModState then
                abilitiesPanel:refreshFromModState()
            end
        end
    end
    ------------------------------------------------------------------

    window:initialise()
    window:addToUIManager()
    window:setVisible(true)
    window.backgroundColor = { r = 0.1, g = 0.1, b = 0.1, a = 0.9 }

    ------------------------------------------------------------------
    -- Main menu label (default visível)
    ------------------------------------------------------------------
    mainLabel = ISLabel:new(width / 2, height / 2, 30, "You are in the Main menu", 1, 1, 1, 1, UIFont.Medium, true)
    mainLabel:initialise()
    mainLabel:setX(mainLabel:getX() - mainLabel:getWidth() / 2)
    mainLabel:setY(mainLabel:getY() - mainLabel:getHeight() / 2)
    window:addChild(mainLabel)

    ------------------------------------------------------------------
    -- Painéis modulares (start hidden)
    ------------------------------------------------------------------
    local function safeAdd(module, parent, name)
        if type(module) == "table" and type(module.addTo) == "function" then
            local panel = module.addTo(parent)
            panel:setVisible(false)
            return panel
        else
            print("[DraggableIconMenu] ERRO: módulo '".. name .."' inválido ou sem addTo(). Criando painel vazio.")
            local fallback = ISPanel:new(0, 0, parent:getWidth(), parent:getHeight())
            fallback:initialise()
            fallback:setVisible(false)
            parent:addChild(fallback)
            return fallback
        end
    end

    infectionPanel = safeAdd(InfectionMenu, window, "InfectionMenu")
    symptomPanel   = safeAdd(SymptomMenu, window, "SymptomMenu")
    abilitiesPanel = safeAdd(AbilitiesMenu, window, "AbilitiesMenu")

    ------------------------------------------------------------------
    -- Botão Close
    ------------------------------------------------------------------
    local closeW, closeH = 80, 30
    closeButton = ISButton:new(width - closeW - 10, height - closeH - 20, closeW, closeH, "Close", window, function()
        window:removeFromUIManager()
        window = nil
    end)
    closeButton:initialise()
    window:addChild(closeButton)

    ------------------------------------------------------------------
    -- Botões top bar (dimensionados proporcionalmente)
    ------------------------------------------------------------------
    local buttonCount = 3
    local margin = 10
    local totalMargin = margin * (buttonCount + 1)
    local buttonW = (width - totalMargin) / buttonCount
    local buttonH = 40

    infectionButton = ISButton:new(margin, 10, buttonW, buttonH, "Infection", window, function()
        mainLabel:setVisible(false)
        infectionPanel:setVisible(true)
        symptomPanel:setVisible(false)
        abilitiesPanel:setVisible(false)
    end)
    infectionButton:initialise()
    window:addChild(infectionButton)

    symptomsButton = ISButton:new(margin * 2 + buttonW, 10, buttonW, buttonH, "Symptoms", window, function()
        mainLabel:setVisible(false)
        infectionPanel:setVisible(false)
        symptomPanel:setVisible(true)
        abilitiesPanel:setVisible(false)
    end)
    symptomsButton:initialise()
    window:addChild(symptomsButton)

    abilitiesButton = ISButton:new(margin * 3 + buttonW * 2, 10, buttonW, buttonH, "Abilities", window, function()
        mainLabel:setVisible(false)
        infectionPanel:setVisible(false)
        symptomPanel:setVisible(false)
        abilitiesPanel:setVisible(true)
    end)
    abilitiesButton:initialise()
    window:addChild(abilitiesButton)
end

-- Function to manually refresh all panels
function DraggableIconMenu.refreshAllPanels()
    if window then
        if infectionPanel and infectionPanel.refreshFromModState then
            infectionPanel:refreshFromModState()
        end
        if symptomPanel and symptomPanel.refreshFromModState then
            symptomPanel:refreshFromModState()
        end
        if abilitiesPanel and abilitiesPanel.refreshFromModState then
            abilitiesPanel:refreshFromModState()
        end
    end
end

-- Function to check if menu is open
function DraggableIconMenu.isOpen()
    return window ~= nil
end

return DraggableIconMenu
