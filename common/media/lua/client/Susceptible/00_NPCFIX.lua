isReapplyingSusceptible = true

local function reapplySusceptibleTraitEarly(playerIndex, player)
    if not player or not player:HasTrait("Susceptible") then 
        isReapplyingSusceptible = false
        return 
    end

    player:getTraits():remove("Susceptible")

    local timer = 0
    local function delayedReapply()
        timer = timer + 1
        if timer >= 45 then -- 틱
            Events.OnPlayerUpdate.Remove(delayedReapply)
            if not player:isDead() then
                player:getTraits():add("Susceptible")
            end
            isReapplyingSusceptible = false
        end
    end

    Events.OnPlayerUpdate.Add(delayedReapply)
end

Events.OnCreatePlayer.Add(reapplySusceptibleTraitEarly)
