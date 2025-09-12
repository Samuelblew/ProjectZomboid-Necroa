-- ForceZedWear - OnTick + Optimized Hysteresis
local ModState = require("ModState")
local SM = ScriptManager.instance

-- Configurações
local ADD_THRESHOLD = 5
local REMOVE_THRESHOLD = 7
local UPDATE_INTERVAL = 10       -- segundos
local UPDATE_RADIUS = 60        -- tiles
local MAX_ICONS = 20
local DEFAULT_LOCKER = "media/textures/locker.png"

-- Regras: FULLTYPE -> Texturas alvo
local RULES = {
    { FULLTYPE = "FZ3.FZ1",  TEXTURES = { "F_ZedBody01_level1", "F_ZedBody01_level2", "F_ZedBody01_level3" } },
    { FULLTYPE = "FZ3.FZ11", TEXTURES = { "F_ZedBody02_level1", "F_ZedBody02_level2", "F_ZedBody02_level3" } },
    { FULLTYPE = "FZ3.FZ12", TEXTURES = { "F_ZedBody04_level1", "F_ZedBody04_level2", "F_ZedBody04_level3" } },
    { FULLTYPE = "FZ3.FZ13", TEXTURES = { "F_ZedBody03_level1", "F_ZedBody03_level2", "F_ZedBody03_level3" } },
}

-- Mapas rápidos
local TEXTURE_TO_ITEM = {}
local MASK_ITEMS = {}
for _, rule in ipairs(RULES) do
    if not SM:getItem(rule.FULLTYPE) then
        print("[ForceZedWear] ERRO: Item " .. rule.FULLTYPE .. " não encontrado.")
    else
        MASK_ITEMS[rule.FULLTYPE] = true
        for _, tex in ipairs(rule.TEXTURES) do
            TEXTURE_TO_ITEM[tex] = rule.FULLTYPE
        end
    end
end

-- Conta ícones ativos
local function countActiveIcons(savedState)
    if not savedState then return 0 end
    local count = 0
    for i = 1, MAX_ICONS do
        local v = savedState["symptomIcon"..i]
        if v and v ~= DEFAULT_LOCKER and tostring(v):match("%S") then
            count = count + 1
        end
    end
    return count
end

-- Atualiza máscara de um zumbi
local function updateZombieMaskVisuals(z, activeIcons)
    if not z or z:isDead() or not z:isFemale() then return end
    local ivs = z:getItemVisuals()
    if not ivs then return end
    local hv = z:getHumanVisual()
    if not hv then return end

    local tex = hv:getSkinTexture()
    if not tex then return end
    local fulltype = TEXTURE_TO_ITEM[tex]
    if not fulltype then return end

    local hasMask = false
    for i = 0, ivs:size()-1 do
        local iv = ivs:get(i)
        if iv and iv:getItemType() == fulltype then
            hasMask = true
            break
        end
    end

    local modelNeedsReset = false

    -- Histérese
    if activeIcons >= ADD_THRESHOLD and not hasMask then
        local newIv = ItemVisual.new()
        newIv:setItemType(fulltype)
        newIv:setClothingItemName(fulltype)
        ivs:add(newIv)
        modelNeedsReset = true
    elseif (activeIcons >= REMOVE_THRESHOLD and hasMask) or (activeIcons < ADD_THRESHOLD and hasMask) then
        for i = ivs:size()-1,0,-1 do
            local iv = ivs:get(i)
            if iv and iv:getItemType() == fulltype then
                ivs:remove(i)
                modelNeedsReset = true
            end
        end
    end

    if modelNeedsReset then
        z:resetModel()
    end
end

-- Atualiza zumbis próximos
local function updateZombiesAroundPlayer(player)
    if not player then return end
    local savedState = ModState.load() or {}
    local activeIcons = countActiveIcons(savedState)

    local cell = player:getCell()
    if not cell then return end
    local zombies = cell:getZombieList()
    if not zombies then return end

    local px, py = player:getX(), player:getY()
    for i = 0, zombies:size()-1 do
        local z = zombies:get(i)
        if z and not z:isDead() then
            local zx, zy = z:getX(), z:getY()
            local dx, dy = px - zx, py - zy
            if dx*dx + dy*dy <= UPDATE_RADIUS*UPDATE_RADIUS then
                updateZombieMaskVisuals(z, activeIcons)
            end
        end
    end
end

-- Protege inventário
local old_isValid = ISInventoryTransferAction.isValid
function ISInventoryTransferAction:isValid()
    if self.srcContainer and self.srcContainer:getType() == "floorzombie" then
        if self.item and MASK_ITEMS[self.item:getFullType()] then
            return false
        end
    end
    return old_isValid(self)
end

-- Timer interno para controlar intervalos
local lastUpdate = 0
Events.OnTick.Add(function()
    local player = getPlayer()
    if not player then return end
    local time = getGameTime():getWorldAgeHours()
    if time - lastUpdate >= UPDATE_INTERVAL / 3600 then
        updateZombiesAroundPlayer(player)
        lastUpdate = time
    end
end)
