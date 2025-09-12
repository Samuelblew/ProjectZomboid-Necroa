local ModState = require("ModState")
local IconInteractionConfig = require("IconInteractionConfig")
local SymptomMenu = {}

-- Load saved state or fallback to default texture
local savedState = ModState.load() or {}

local iconTexture1  = savedState.symptomIcon1  or "media/textures/locker.png"
local iconTexture2  = savedState.symptomIcon2  or "media/textures/locker.png"
local iconTexture3  = savedState.symptomIcon3  or "media/textures/locker.png"
local iconTexture4  = savedState.symptomIcon4  or "media/textures/locker.png"
local iconTexture5  = savedState.symptomIcon5  or "media/textures/locker.png"
local iconTexture6  = savedState.symptomIcon6  or "media/textures/locker.png"
local iconTexture7  = savedState.symptomIcon7  or "media/textures/locker.png"
local iconTexture8  = savedState.symptomIcon8  or "media/textures/locker.png"
local iconTexture9  = savedState.symptomIcon9  or "media/textures/locker.png"
local iconTexture10  = savedState.symptomIcon10  or "media/textures/locker.png"
local iconTexture11  = savedState.symptomIcon11  or "media/textures/locker.png"
local iconTexture12  = savedState.symptomIcon12  or "media/textures/locker.png"
local iconTexture13  = savedState.symptomIcon13  or "media/textures/locker.png"
local iconTexture14  = savedState.symptomIcon14  or "media/textures/locker.png"
local iconTexture15  = savedState.symptomIcon15  or "media/textures/locker.png"
local iconTexture16  = savedState.symptomIcon16  or "media/textures/locker.png"
local iconTexture17  = savedState.symptomIcon17  or "media/textures/locker.png"
local iconTexture18  = savedState.symptomIcon18  or "media/textures/locker.png"
local iconTexture19  = savedState.symptomIcon19  or "media/textures/locker.png"
local iconTexture20  = savedState.symptomIcon20  or "media/textures/locker.png"
local iconTexture21  = savedState.symptomIcon21  or "media/textures/locker.png"
local iconTexture22  = savedState.symptomIcon22  or "media/textures/locker.png"
local iconTexture23  = savedState.symptomIcon23  or "media/textures/locker.png"
local iconTexture24  = savedState.symptomIcon24  or "media/textures/locker.png"
local iconTexture25  = savedState.symptomIcon25  or "media/textures/locker.png"
local iconTexture26  = savedState.symptomIcon26  or "media/textures/locker.png"
local iconTexture27  = savedState.symptomIcon27  or "media/textures/locker.png"
local iconTexture28  = savedState.symptomIcon28  or "media/textures/locker.png"
local iconTexture29  = savedState.symptomIcon29  or "media/textures/locker.png"
local iconTexture30  = savedState.symptomIcon30  or "media/textures/locker.png"
local iconTexture31  = savedState.symptomIcon31  or "media/textures/locker.png"

-- Base icons with positions (based on 1280x800)
local baseIcons = {
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture1,  x = 590, y = 370 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture2,  x = 590, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture3,  x = 680, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture4,  x = 770, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture5,  x = 860, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture6,  x = 860, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture7,  x = 950, y = 570 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture8,  x = 950, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture9,  x = 950, y = 370 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture10,  x = 1040, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture11,  x = 680, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture12,  x = 770, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture13,  x = 590, y = 670 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture14,  x = 500, y = 620 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture15,  x = 500, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture16,  x = 410, y = 570 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture17,  x = 410, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture18,  x = 320, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture19,  x = 230, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture20,  x = 590, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture21,  x = 590, y = 170 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture22,  x = 680, y = 320 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture23,  x = 680, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture24,  x = 770, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture25,  x = 860, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture26,  x = 950, y = 170 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture27,  x = 500, y = 320 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture28,  x = 500, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture29,  x = 410, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture30,  x = 320, y = 220 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture31,  x = 230, y = 170 }
}

-- Scale icons to panel size
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
local SymptomPanel = ISPanel:derive("SymptomPanel")

function SymptomPanel:initialise()
    ISPanel.initialise(self)
    self.iconSize = 100 * (self:getHeight() / 800)
    self:setCapture(true)
    self.icons = getScaledIcons(self:getWidth(), self:getHeight())
    self.iconsOriginal = baseIcons
end

function SymptomPanel:prerender()
    ISPanel.prerender(self)
    -- Recalculate icons on resize
    self.icons = getScaledIcons(self:getWidth(), self:getHeight())
    self.iconSize = 100 * (self:getHeight() / 800)
end

-- Function to refresh icons from ModState
function SymptomPanel:refreshFromModState()
    local newSavedState = ModState.load() or {}
    
    -- Check if any symptom icons have changed
    local hasChanges = false
    for i = 1, 31 do
        local newTexture = newSavedState["symptomIcon" .. i] or "media/textures/locker.png"
        if self.iconsOriginal[i].texturePath ~= newTexture then
            self.iconsOriginal[i].texturePath = newTexture
            hasChanges = true
        end
    end
    
    -- If there were changes, update the scaled icons and save state
    if hasChanges then
        self.icons = getScaledIcons(self:getWidth(), self:getHeight())
        -- Update savedState to match the new state
        for i = 1, 31 do
            savedState["symptomIcon" .. i] = self.iconsOriginal[i].texturePath
        end
    end
end

function SymptomPanel:render()
    ISPanel.render(self)
    for _, icon in ipairs(self.icons) do
        local tex = getTexture(icon.texturePath)
        if tex then
            self:drawTextureScaled(tex, icon.x, icon.y, self.iconSize, self.iconSize, 1, 1, 1, 1)
        end
    end
end

function SymptomPanel:onMouseDown(x, y)
    -- Verifica se a interação está habilitada via configuração
    if not IconInteractionConfig.isInteractionEnabled() then
        return false -- Não processa clique se interação estiver desabilitada
    end
    
    for i, icon in ipairs(self.icons) do
        local inside = x >= icon.x and x <= icon.x + self.iconSize and
                       y >= icon.y and y <= icon.y + self.iconSize
        if inside then
            if i == 1 then
                icon.texturePath = (icon.texturePath == "media/textures/Cytopathic_Reanimation_Icon.png") and icon.originalTexture or "media/textures/Cytopathic_Reanimation_Icon.png"
            elseif i == 2 then
                icon.texturePath = (icon.texturePath == "media/textures/Anaerobic_Resuscitation_Icon.png") and icon.originalTexture or "media/textures/Anaerobic_Resuscitation_Icon.png"
            elseif i == 3 then
                icon.texturePath = (icon.texturePath == "media/textures/EMC.png") and icon.originalTexture or "media/textures/EMC.png"
            elseif i == 4 then
                icon.texturePath = (icon.texturePath == "media/textures/PS.png") and icon.originalTexture or "media/textures/PS.png"
            elseif i == 5 then
                icon.texturePath = (icon.texturePath == "media/textures/DC.png") and icon.originalTexture or "media/textures/DC.png"
            elseif i == 6 then
                icon.texturePath = (icon.texturePath == "media/textures/AR.png") and icon.originalTexture or "media/textures/AR.png"
            elseif i == 7 then
                icon.texturePath = (icon.texturePath == "media/textures/NM.png") and icon.originalTexture or "media/textures/NM.png"
            elseif i == 8 then
                icon.texturePath = (icon.texturePath == "media/textures/Autothysis.png") and icon.originalTexture or "media/textures/Autothysis.png"
            elseif i == 9 then
                icon.texturePath = (icon.texturePath == "media/textures/CE.png") and icon.originalTexture or "media/textures/CE.png"
            elseif i == 10 then
                icon.texturePath = (icon.texturePath == "media/textures/BD.png") and icon.originalTexture or "media/textures/BD.png"
            elseif i == 11 then
                icon.texturePath = (icon.texturePath == "media/textures/MT.png") and icon.originalTexture or "media/textures/MT.png"
            elseif i == 12 then
                icon.texturePath = (icon.texturePath == "media/textures/AB.png") and icon.originalTexture or "media/textures/AB.png"
            elseif i == 13 then
                icon.texturePath = (icon.texturePath == "media/textures/LH.png") and icon.originalTexture or "media/textures/LH.png"
            elseif i == 14 then
                icon.texturePath = (icon.texturePath == "media/textures/AS.png") and icon.originalTexture or "media/textures/AS.png"
            elseif i == 15 then
                icon.texturePath = (icon.texturePath == "media/textures/ES.png") and icon.originalTexture or "media/textures/ES.png"
            elseif i == 16 then
                icon.texturePath = (icon.texturePath == "media/textures/Hyperosmia.png") and icon.originalTexture or "media/textures/Hyperosmia.png"
            elseif i == 17 then
                icon.texturePath = (icon.texturePath == "media/textures/TL.png") and icon.originalTexture or "media/textures/TL.png"
            elseif i == 18 then
                icon.texturePath = (icon.texturePath == "media/textures/CS.png") and icon.originalTexture or "media/textures/CS.png"
            elseif i == 19 then
                icon.texturePath = (icon.texturePath == "media/textures/VH.png") and icon.originalTexture or "media/textures/VH.png"
            elseif i == 20 then
                icon.texturePath = (icon.texturePath == "media/textures/Psychosis.png") and icon.originalTexture or "media/textures/Psychosis.png"
            elseif i == 21 then
                icon.texturePath = (icon.texturePath == "media/textures/AE.png") and icon.originalTexture or "media/textures/AE.png"
            elseif i == 22 then
                icon.texturePath = (icon.texturePath == "media/textures/Cannibalism.png") and icon.originalTexture or "media/textures/Cannibalism.png"
            elseif i == 23 then
                icon.texturePath = (icon.texturePath == "media/textures/Autophagia.png") and icon.originalTexture or "media/textures/Autophagia.png"
            elseif i == 24 then
                icon.texturePath = (icon.texturePath == "media/textures/Gastroenteritis.png") and icon.originalTexture or "media/textures/Gastroenteritis.png"
            elseif i == 25 then
                icon.texturePath = (icon.texturePath == "media/textures/Polyphagia.png") and icon.originalTexture or "media/textures/Polyphagia.png"
            elseif i == 26 then
                icon.texturePath = (icon.texturePath == "media/textures/HS.png") and icon.originalTexture or "media/textures/HS.png"
            elseif i == 27 then
                icon.texturePath = (icon.texturePath == "media/textures/Paranoia.png") and icon.originalTexture or "media/textures/Paranoia.png"
            elseif i == 28 then
                icon.texturePath = (icon.texturePath == "media/textures/Coma.png") and icon.originalTexture or "media/textures/Coma.png"
            elseif i == 29 then
                icon.texturePath = (icon.texturePath == "media/textures/PhotophobiaIcon.png") and icon.originalTexture or "media/textures/PhotophobiaIcon.png"
            elseif i == 30 then
                icon.texturePath = (icon.texturePath == "media/textures/Fever.png") and icon.originalTexture or "media/textures/Fever.png"
            elseif i == 31 then
                icon.texturePath = (icon.texturePath == "media/textures/Insomnia.png") and icon.originalTexture or "media/textures/Insomnia.png"
            end

            -- Save persistent state
            for j = 1, #self.icons do
                savedState["symptomIcon" .. j] = self.icons[j].texturePath
                self.iconsOriginal[j].texturePath = self.icons[j].texturePath
            end
            ModState.save(savedState)
            return true
        end
    end
    return false
end

-- Function to add panel to parent window
function SymptomMenu.addTo(parentWindow)
    local w, h = parentWindow:getWidth(), parentWindow:getHeight()
    local panel = SymptomPanel:new(0, 0, w, h)
    panel.iconsOriginal = baseIcons
    panel:initialise()
    panel:setVisible(false)
    parentWindow:addChild(panel)
    return panel
end

return SymptomMenu
