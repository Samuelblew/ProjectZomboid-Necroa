local config = require("DraggableIcon_Options")
local uiMenu = require("DraggableIcon_Menu")

local textureSize = 64
local Icon = nil
local dragging = false
local offsetX, offsetY = 0, 0

DraggableIcon = ISUIElement:derive("DraggableIcon")

function DraggableIcon:new(x, y, width, height)
    local o = ISUIElement.new(self)
    o.x = x
    o.y = y
    o.width = width
    o.height = height
    return o
end

function DraggableIcon:initialise()
    ISUIElement.initialise(self)
    self:updateSize()
    self:setX(getCore():getScreenWidth() - self:getWidth() - 175)
    self:setY(8)
    self:addToUIManager()
    self:setVisible(true)
    self:setCapture(true)
end

function DraggableIcon:updateSize()
    local size = config.IconSize or 46
    self:setWidth(size)
    self:setHeight(size)
end

function DraggableIcon:render()
    local texture = getTexture("media/textures/plague_icon.png")
    if texture then
        local scale = self:getWidth() / textureSize
        self:drawTextureScaled(texture, 0, 0, textureSize * scale, textureSize * scale, 1, 1, 1, 1)
    end
end

function DraggableIcon:onMouseDown(x, y)
    if self:isMouseOver(x, y) then
        dragging = true
        offsetX = x
        offsetY = y
        self:setCapture(true)
        return true
    end
    return false
end

function DraggableIcon:onMouseUp(x, y)
    dragging = false
    self:setCapture(false)

    -- Open the simple box when clicked
    if self:isMouseOver(x, y) then
        uiMenu.showMenu()
    end

    return true
end

function DraggableIcon:onMouseMove(dx, dy)
    if dragging then
        self:setX(self:getX() + dx)
        self:setY(self:getY() + dy)
        return true
    end
    return false
end

function DraggableIcon:onMouseMoveOutside(dx, dy)
    return self:onMouseMove(dx, dy)
end

Events.OnCreatePlayer.Add(function(playerIndex)
    if not Icon then
        Icon = DraggableIcon:new(0, 0, 0, 0)
        Icon:initialise()
        print("DraggableIcon created.")
    end
end)

if config and config.onApply then
    config.onApply(function()
        if Icon then
            Icon:updateSize()
            print("Icon size updated.")
        end
    end)
end
