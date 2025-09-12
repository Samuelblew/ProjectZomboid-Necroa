local ModState = require("ModState")
local IconInteractionConfig = require("IconInteractionConfig")
local AbilitiesMenu = {}

-- Load saved state or fallback to default
local savedState = ModState.load() or {}

local iconTexture1  = savedState.abilityIcon1  or "media/textures/locker.png"
local iconTexture2  = savedState.abilityIcon2  or "media/textures/locker.png"
local iconTexture3  = savedState.abilityIcon3  or "media/textures/locker.png"
local iconTexture4  = savedState.abilityIcon4  or "media/textures/locker.png"
local iconTexture5  = savedState.abilityIcon5  or "media/textures/locker.png"
local iconTexture6  = savedState.abilityIcon6  or "media/textures/locker.png"
local iconTexture7  = savedState.abilityIcon7  or "media/textures/locker.png"
local iconTexture8  = savedState.abilityIcon8  or "media/textures/locker.png"
local iconTexture9  = savedState.abilityIcon9  or "media/textures/locker.png"
local iconTexture10  = savedState.abilityIcon10  or "media/textures/locker.png"
local iconTexture11  = savedState.abilityIcon11  or "media/textures/locker.png"
local iconTexture12  = savedState.abilityIcon12  or "media/textures/locker.png"
local iconTexture13  = savedState.abilityIcon13  or "media/textures/locker.png"
local iconTexture14  = savedState.abilityIcon14  or "media/textures/locker.png"
local iconTexture15  = savedState.abilityIcon15  or "media/textures/locker.png"
local iconTexture16  = savedState.abilityIcon16  or "media/textures/locker.png"
local iconTexture17  = savedState.abilityIcon17  or "media/textures/locker.png"
local iconTexture18  = savedState.abilityIcon18  or "media/textures/locker.png"
local iconTexture19  = savedState.abilityIcon19  or "media/textures/locker.png"
local iconTexture20  = savedState.abilityIcon20  or "media/textures/locker.png"
local iconTexture21  = savedState.abilityIcon21  or "media/textures/locker.png"
local iconTexture22  = savedState.abilityIcon22  or "media/textures/locker.png"
local iconTexture23  = savedState.abilityIcon23  or "media/textures/locker.png"
local iconTexture24  = savedState.abilityIcon24  or "media/textures/locker.png"
local iconTexture25  = savedState.abilityIcon25  or "media/textures/locker.png"
local iconTexture26  = savedState.abilityIcon26  or "media/textures/locker.png"
local iconTexture27  = savedState.abilityIcon27  or "media/textures/locker.png"
local iconTexture28  = savedState.abilityIcon28  or "media/textures/locker.png"

-- Base icons (positions for 1280x800 screen)
local baseIcons = {
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture1,  x = 590, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture2,  x = 680, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture3,  x = 770, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture4,  x = 770, y = 170 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture5,  x = 860, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture6,  x = 950, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture7,  x = 680, y = 320 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture8,  x = 680, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture9,  x = 590, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture10,  x = 500, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture11,  x = 590, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture12,  x = 680, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture13,  x = 950, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture14,  x = 1040, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture15,  x = 1040, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture16,  x = 860, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture17,  x = 860, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture18,  x = 860, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture19,  x = 180, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture20,  x = 275, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture21,  x = 180, y = 570 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture22,  x = 275, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture23,  x = 180, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture24,  x = 180, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture25,  x = 180, y = 170 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture26,  x = 270, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture27,  x = 360, y = 170 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture28,  x = 360, y = 270 }


}

-- Scale icons to match resolution
local function getScaledIcons(width, height)
    local scaleX = width / 1280
    local scaleY = height / 800
    local result = {}
    for _, icon in ipairs(baseIcons) do
        table.insert(result, {
            originalTexture = icon.originalTexture,
            texturePath = icon.texturePath,
            x = math.floor(icon.x * scaleX),
            y = math.floor(icon.y * scaleY),
        })
    end
    return result
end

-- Main Panel
local AbilitiesPanel = ISPanel:derive("AbilitiesPanel")

function AbilitiesPanel:initialise()
    ISPanel.initialise(self)
    self.iconSize = 100 * (self:getHeight() / 800)
    self:setCapture(true)
    self.icons = getScaledIcons(self:getWidth(), self:getHeight())
    self.iconsOriginal = baseIcons
end

function AbilitiesPanel:prerender()
    ISPanel.prerender(self)
    self.icons = getScaledIcons(self:getWidth(), self:getHeight())
    self.iconSize = 100 * (self:getHeight() / 800)
end

-- Function to refresh icons from ModState
function AbilitiesPanel:refreshFromModState()
    local newSavedState = ModState.load() or {}
    
    -- Check if any ability icons have changed
    local hasChanges = false
    for i = 1, 28 do
        local newTexture = newSavedState["abilityIcon" .. i] or "media/textures/locker.png"
        if self.iconsOriginal[i].texturePath ~= newTexture then
            self.iconsOriginal[i].texturePath = newTexture
            hasChanges = true
        end
    end
    
    -- If there were changes, update the scaled icons and save state
    if hasChanges then
        self.icons = getScaledIcons(self:getWidth(), self:getHeight())
        -- Update savedState to match the new state
        for i = 1, 28 do
            savedState["abilityIcon" .. i] = self.iconsOriginal[i].texturePath
        end
    end
end

function AbilitiesPanel:render()
    ISPanel.render(self)
    for _, icon in ipairs(self.icons) do
        local tex = getTexture(icon.texturePath)
        if tex then
            self:drawTextureScaled(tex, icon.x, icon.y, self.iconSize, self.iconSize, 1, 1, 1, 1)
        end
    end
end

function AbilitiesPanel:onMouseDown(x, y)
    -- Verifica se a interação está habilitada via configuração
    if not IconInteractionConfig.isInteractionEnabled() then
        return false -- Não processa clique se interação estiver desabilitada
    end
    
    for i, icon in ipairs(self.icons) do
        local inside = x >= icon.x and x <= icon.x + self.iconSize and
                       y >= icon.y and y <= icon.y + self.iconSize
        if inside then
            if i == 1 then
                icon.texturePath = (icon.texturePath == "media/textures/HI.png") and icon.originalTexture or "media/textures/HI.png"
            elseif i == 2 then
                icon.texturePath = (icon.texturePath == "media/textures/ST.png") and icon.originalTexture or "media/textures/ST.png"
            elseif i == 3 then
                icon.texturePath = (icon.texturePath == "media/textures/DM.png") and icon.originalTexture or "media/textures/DM.png"
            elseif i == 4 then
                icon.texturePath = (icon.texturePath == "media/textures/DF.png") and icon.originalTexture or "media/textures/DF.png"
            elseif i == 5 then
                icon.texturePath = (icon.texturePath == "media/textures/Echopraxia.png") and icon.originalTexture or "media/textures/Echopraxia.png"
            elseif i == 6 then
                icon.texturePath = (icon.texturePath == "media/textures/EQ.png") and icon.originalTexture or "media/textures/EQ.png"
            elseif i == 7 then
                icon.texturePath = (icon.texturePath == "media/textures/HI1.png") and icon.originalTexture or "media/textures/HI1.png"
            elseif i == 8 then
                icon.texturePath = (icon.texturePath == "media/textures/HV.png") and icon.originalTexture or "media/textures/HV.png"
            elseif i == 9 then
                icon.texturePath = (icon.texturePath == "media/textures/HP.png") and icon.originalTexture or "media/textures/HP.png"
            elseif i == 10 then
                icon.texturePath = (icon.texturePath == "media/textures/DR.png") and icon.originalTexture or "media/textures/DR.png"
            elseif i == 11 then
                icon.texturePath = (icon.texturePath == "media/textures/PR.png") and icon.originalTexture or "media/textures/PR.png"
            elseif i == 12 then
                icon.texturePath = (icon.texturePath == "media/textures/LR.png") and icon.originalTexture or "media/textures/LR.png"
            elseif i == 13 then
                icon.texturePath = (icon.texturePath == "media/textures/RA.png") and icon.originalTexture or "media/textures/RA.png"
            elseif i == 14 then
                icon.texturePath = (icon.texturePath == "media/textures/AP.png") and icon.originalTexture or "media/textures/AP.png"
            elseif i == 15 then
                icon.texturePath = (icon.texturePath == "media/textures/LN.png") and icon.originalTexture or "media/textures/LN.png"
            elseif i == 16 then
                icon.texturePath = (icon.texturePath == "media/textures/RB.png") and icon.originalTexture or "media/textures/RB.png"
            elseif i == 17 then
                icon.texturePath = (icon.texturePath == "media/textures/ED.png") and icon.originalTexture or "media/textures/ED.png"
            elseif i == 18 then
                icon.texturePath = (icon.texturePath == "media/textures/CM.png") and icon.originalTexture or "media/textures/CM.png"
            elseif i == 19 then
                icon.texturePath = (icon.texturePath == "media/textures/DR1.png") and icon.originalTexture or "media/textures/DR1.png"
            elseif i == 20 then
                icon.texturePath = (icon.texturePath == "media/textures/DR2.png") and icon.originalTexture or "media/textures/DR2.png"
            elseif i == 21 then
                icon.texturePath = (icon.texturePath == "media/textures/GH.png") and icon.originalTexture or "media/textures/GH.png"
            elseif i == 22 then
                icon.texturePath = (icon.texturePath == "media/textures/GR1.png") and icon.originalTexture or "media/textures/GR1.png"
            elseif i == 23 then
                icon.texturePath = (icon.texturePath == "media/textures/GR2.png") and icon.originalTexture or "media/textures/GR2.png"
            elseif i == 24 then
                icon.texturePath = (icon.texturePath == "media/textures/HR2.png") and icon.originalTexture or "media/textures/HR2.png"
            elseif i == 25 then
                icon.texturePath = (icon.texturePath == "media/textures/HR1.png") and icon.originalTexture or "media/textures/HR1.png"
            elseif i == 26 then
                icon.texturePath = (icon.texturePath == "media/textures/Mummification.png") and icon.originalTexture or "media/textures/Mummification.png"
            elseif i == 27 then
                icon.texturePath = (icon.texturePath == "media/textures/CR1.png") and icon.originalTexture or "media/textures/CR1.png"
            elseif i == 28 then
                icon.texturePath = (icon.texturePath == "media/textures/CR2.png") and icon.originalTexture or "media/textures/CR2.png"
            end

            -- Save persistent state
            for j = 1, #self.icons do
                savedState["abilityIcon" .. j] = self.icons[j].texturePath
                self.iconsOriginal[j].texturePath = self.icons[j].texturePath
            end
            ModState.save(savedState)
            return true
        end
    end
    return false
end

-- Function to add panel to parent window
function AbilitiesMenu.addTo(parentWindow)
    local w, h = parentWindow:getWidth(), parentWindow:getHeight()
    local panel = AbilitiesPanel:new(0, 0, w, h)
    panel.iconsOriginal = baseIcons
    panel:initialise()
    panel:setVisible(false)
    parentWindow:addChild(panel)
    return panel
end

return AbilitiesMenu
