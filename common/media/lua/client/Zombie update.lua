local ModState = require("ModState")

-- ===================================================================
-- Reprocessa zumbis próximos
-- ===================================================================
local function processNearbyZombies()
    local player = getPlayer()
    if not player then return end

    local zombieList = player:getCell():getZombieList()
    local px, py, pz = player:getX(), player:getY(), player:getZ()
    local radius = 60 -- ajuste conforme necessário

    for i = 0, zombieList:size() - 1 do
        local z = zombieList:get(i)
        local dx = z:getX() - px
        local dy = z:getY() - py
        local distSq = dx*dx + dy*dy
        if distSq <= radius*radius then
            z:makeInactive(true)
            z:DoZombieStats()
            z:makeInactive(false)
        end
    end
end

-- ===================================================================
-- Reprocessa 3 vezes seguidas
-- ===================================================================
local function processThreeTimes()
    for i = 1, 3 do
        processNearbyZombies()
    end
end

-- ===================================================================
-- Estado anterior para comparação
-- ===================================================================
local lastSavedState = ModState.load() or {}

-- ===================================================================
-- Timer baseado em ticks
-- ===================================================================
local tickCount = 0
local tickInterval = 120 -- a cada 120 ticks (~2s)
local function checkIconsOnInterval()
    tickCount = tickCount + 1
    if tickCount < tickInterval then return end
    tickCount = 0

    local savedState = ModState.load() or {}

    -- 🔹 Checa symptomIcons (1..31)
    for i = 1, 31 do
        local key = "symptomIcon" .. i
        if lastSavedState[key] ~= savedState[key] then
            processThreeTimes()
            print("[ZombieUpdater] Symptom Icon changed: " .. key .. " -> " .. tostring(savedState[key]))
        end
    end

    -- 🔹 Checa abilityIcons (1..28)
    for i = 1, 28 do
        local key = "abilityIcon" .. i
        if lastSavedState[key] ~= savedState[key] then
            processThreeTimes()
            print("[ZombieUpdater] Ability Icon changed: " .. key .. " -> " .. tostring(savedState[key]))
        end
    end

    -- Atualiza estado anterior
    lastSavedState = savedState
end

-- ===================================================================
-- Habilita e desabilita o updater
-- ===================================================================
function UpdateZombieStats_Enable()
    Events.OnTick.Remove(checkIconsOnInterval)
    Events.OnTick.Add(checkIconsOnInterval)
end

function UpdateZombieStats_Disable()
    Events.OnTick.Remove(checkIconsOnInterval)
end

-- ===================================================================
-- Auto start
-- ===================================================================
Events.OnGameStart.Add(UpdateZombieStats_Enable)
