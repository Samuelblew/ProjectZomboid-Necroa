local ModState = require("ModState")

local LH = {}
LH.lastIcon1 = nil

local function OnPlayerUpdate(player)
    if not player or player:isDead() then return end

    local savedState = ModState.load() or {}
    local icon1 = tostring(savedState.symptomIcon13 or "media/textures/locker.png"):gsub("%s+$", "")

    -- only apply freeze logic when LH.png is active
    if icon1 == "media/textures/LH.png" then
        local attackers = player:getSurroundingAttackingZombies()
        local shouldBlock = attackers > 0
        if player:isBlockMovement() ~= shouldBlock then
            player:setBlockMovement(shouldBlock)
        end
    else
        -- if LH.png is not active, make sure movement isn't blocked
        if player:isBlockMovement() then
            player:setBlockMovement(false)
        end
    end
end

Events.OnPlayerUpdate.Add(OnPlayerUpdate)
