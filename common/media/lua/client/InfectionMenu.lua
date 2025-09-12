local ModState = require("ModState")
local IconInteractionConfig = require("IconInteractionConfig")
local InfectionMenu = {}

-- Load icon state from saved ModState or fallback to default
local savedState  = ModState.load() or {}
local iconTexture1 = savedState.infectionIcon1 or "media/textures/locker.png"
local iconTexture2 = savedState.infectionIcon2 or "media/textures/locker.png"
local iconTexture3 = savedState.infectionIcon3 or "media/textures/locker.png"
local iconTexture4 = savedState.infectionIcon4 or "media/textures/locker.png"
local iconTexture5 = savedState.infectionIcon5 or "media/textures/locker.png"
local iconTexture6 = savedState.infectionIcon6 or "media/textures/locker.png"
local iconTexture7 = savedState.infectionIcon7 or "media/textures/locker.png"
local iconTexture8 = savedState.infectionIcon8 or "media/textures/locker.png"
local iconTexture9 = savedState.infectionIcon9 or "media/textures/locker.png"
local iconTexture10 = savedState.infectionIcon10 or "media/textures/locker.png"
local iconTexture11 = savedState.infectionIcon11 or "media/textures/locker.png"
local iconTexture12 = savedState.infectionIcon12 or "media/textures/locker.png"
local iconTexture13 = savedState.infectionIcon13 or "media/textures/locker.png"
local iconTexture14 = savedState.infectionIcon14 or "media/textures/locker.png"
local iconTexture15 = savedState.infectionIcon15 or "media/textures/locker.png"
local iconTexture16 = savedState.infectionIcon16 or "media/textures/locker.png"
local iconTexture17 = savedState.infectionIcon17 or "media/textures/locker.png"
local iconTexture18 = savedState.infectionIcon18 or "media/textures/locker.png"
local iconTexture19 = savedState.infectionIcon19 or "media/textures/locker.png"
local iconTexture20 = savedState.infectionIcon20 or "media/textures/locker.png"

-- Ícones base com posições ajustadas (base de 1280x800)
local baseIcons = {
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture1,  x = 280, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture2,  x = 185, y = 520 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture3,  x = 280, y = 370 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture4,  x = 375, y = 420 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture5,  x = 470, y = 470 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture6,  x = 185, y = 320 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture7,  x = 375, y = 320 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture8,  x = 470, y = 270 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture9,  x = 730, y = 380 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture10, x = 730, y = 280 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture11, x = 825, y = 330 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture12, x = 825, y = 230 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture13, x = 730, y = 180 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture14, x = 730, y = 480 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture15, x = 825, y = 530 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture16, x = 920, y = 580 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture17, x = 825, y = 630 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture18, x = 920, y = 480 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture19, x = 1015, y = 530 },
    { originalTexture = "media/textures/locker.png", texturePath = iconTexture20, x = 1005, y = 230 }
}

-- Gera ícones proporcionais à nova resolução
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

------------------------------------------------------------------
-- InfectionPanel
------------------------------------------------------------------
local InfectionPanel = ISPanel:derive("InfectionPanel")

function InfectionPanel:initialise()
    ISPanel.initialise(self)
    self.iconSize = 100 * (self:getHeight() / 800)
    self:setCapture(true)
    self.icons = getScaledIcons(self:getWidth(), self:getHeight())
    self.iconsOriginal = baseIcons  -- Adiciona referência para atualizar o estado persistente
end

function InfectionPanel:render()
    ISPanel.render(self)
    for _, icon in ipairs(self.icons) do
        local tex = getTexture(icon.texturePath)
        if tex then
            self:drawTextureScaled(tex, icon.x, icon.y, self.iconSize, self.iconSize, 1, 1, 1, 1)
        end
    end
end

-- Function to refresh icons from ModState
function InfectionPanel:refreshFromModState()
    local newSavedState = ModState.load() or {}
    
    -- Check if any infection icons have changed
    local hasChanges = false
    for i = 1, 20 do
        local newTexture = newSavedState["infectionIcon" .. i] or "media/textures/locker.png"
        if self.iconsOriginal[i].texturePath ~= newTexture then
            self.iconsOriginal[i].texturePath = newTexture
            hasChanges = true
        end
    end
    
    -- If there were changes, update the scaled icons and save state
    if hasChanges then
        self.icons = getScaledIcons(self:getWidth(), self:getHeight())
        -- Update savedState to match the new state
        for i = 1, 20 do
            savedState["infectionIcon" .. i] = self.iconsOriginal[i].texturePath
        end
    end
end

function InfectionPanel:onMouseDown(x, y)
    -- Verifica se a interação está habilitada via configuração
    if not IconInteractionConfig.isInteractionEnabled() then
        return false -- Não processa clique se interação estiver desabilitada
    end
    
    for i, icon in ipairs(self.icons) do
        local inside = x >= icon.x and x <= icon.x + self.iconSize and
                       y >= icon.y and y <= icon.y + self.iconSize
        if inside then
            if i == 1 then
                icon.texturePath = (icon.texturePath == "media/textures/Bird_Icon.png") and icon.originalTexture or "media/textures/Bird_Icon.png"
            elseif i == 2 then
                icon.texturePath = (icon.texturePath == "media/textures/Bird_Iconblack.png") and icon.originalTexture or "media/textures/Bird_Iconblack.png"
            elseif i == 3 then
                icon.texturePath = (icon.texturePath == "media/textures/Zoonotic_Icon.png") and icon.originalTexture or "media/textures/Zoonotic_Icon.png"
            elseif i == 4 then
                icon.texturePath = (icon.texturePath == "media/textures/Rodent_Icon.png") and icon.originalTexture or "media/textures/Rodent_Icon.png"
            elseif i == 5 then
                icon.texturePath = (icon.texturePath == "media/textures/Rodent_Iconblack.png") and icon.originalTexture or "media/textures/Rodent_Iconblack.png"
            elseif i == 6 then
                icon.texturePath = (icon.texturePath == "media/textures/Insect_Icon.png") and icon.originalTexture or "media/textures/Insect_Icon.png"
            elseif i == 7 then
                icon.texturePath = (icon.texturePath == "media/textures/Bat_Icon.png") and icon.originalTexture or "media/textures/Bat_Icon.png"
            elseif i == 8 then
                icon.texturePath = (icon.texturePath == "media/textures/Bat_Iconblack.png") and icon.originalTexture or "media/textures/Bat_Iconblack.png"
            elseif i == 9 then
                icon.texturePath = (icon.texturePath == "media/textures/Blood_Icon.png") and icon.originalTexture or "media/textures/Blood_Icon.png"
            elseif i == 10 then
                icon.texturePath = (icon.texturePath == "media/textures/Blood_Icon2.png") and icon.originalTexture or "media/textures/Blood_Icon2.png"
            elseif i == 11 then
                icon.texturePath = (icon.texturePath == "media/textures/Air_Icon.png") and icon.originalTexture or "media/textures/Air_Icon.png"
            elseif i == 12 then
                icon.texturePath = (icon.texturePath == "media/textures/Air_Icon2.png") and icon.originalTexture or "media/textures/Air_Icon2.png"
            elseif i == 13 then
                icon.texturePath = (icon.texturePath == "media/textures/Air_Icon3.png") and icon.originalTexture or "media/textures/Air_Icon3.png"
            elseif i == 14 then
                icon.texturePath = (icon.texturePath == "media/textures/Urogenital_Icon.png") and icon.originalTexture or "media/textures/Urogenital_Icon.png"
            elseif i == 15 then
                icon.texturePath = (icon.texturePath == "media/textures/Saliva_Icon.png") and icon.originalTexture or "media/textures/Saliva_Icon.png"
            elseif i == 16 then
                icon.texturePath = (icon.texturePath == "media/textures/Saliva_Icon2.png") and icon.originalTexture or "media/textures/Saliva_Icon2.png"
            elseif i == 17 then
                icon.texturePath = (icon.texturePath == "media/textures/Nausea_Icon.png") and icon.originalTexture or "media/textures/Nausea_Icon.png"
            elseif i == 18 then
                icon.texturePath = (icon.texturePath == "media/textures/Water_Icon.png") and icon.originalTexture or "media/textures/Water_Icon.png"
            elseif i == 19 then
                icon.texturePath = (icon.texturePath == "media/textures/Water_Icon2.png") and icon.originalTexture or "media/textures/Water_Icon2.png"
            elseif i == 20 then
                icon.texturePath = (icon.texturePath == "media/textures/Genome_Icon.png") and icon.originalTexture or "media/textures/Genome_Icon.png" 
            end

            -- Atualiza o estado persistente para salvar no arquivo
            for j = 1, 20 do
                savedState["infectionIcon" .. j] = self.icons[j].texturePath
                -- Atualiza também o estado original para manter sessão coerente
                self.iconsOriginal[j].texturePath = self.icons[j].texturePath
            end
            ModState.save(savedState)

            return true
        end
    end
    return false
end

------------------------------------------------------------------
function InfectionMenu.addTo(parentWindow)
    local w, h = parentWindow:getWidth(), parentWindow:getHeight()
    local panel = InfectionPanel:new(0, 0, w, h)
    panel.iconsOriginal = baseIcons -- importante para manter referência do estado real
    panel:initialise()
    panel:setVisible(false)
    parentWindow:addChild(panel)
    return panel
end

return InfectionMenu
