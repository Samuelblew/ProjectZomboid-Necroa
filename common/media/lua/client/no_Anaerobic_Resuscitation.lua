local ModState = require("ModState")

SprintersNights_Symptom = SprintersNights_Symptom or {}
SprintersNights_Symptom.lastIcon1 = nil
SprintersNights_Symptom.tripEnabled = false
SprintersNights_Symptom.invisibleEnabled = false -- flag para invisibilidade

--==================================================
--  Zombie Trip Mod - Build 42 (adaptado)
--==================================================
local CHANCE_TRIP_RUNNER_RANDOM   = 90
local CHANCE_TRIP_SHAMBLER_RANDOM = 90
local CHANCE_TRIP_RUNNER_COLLIDE  = 95
local CHANCE_TRIP_SHAMBLER_COLLIDE= 95
local CHASE_MULTIPLIER = 2
local TICK_MIN = 100
local TICK_MAX = 150

local function isRunnerZombie(zombie)
    local speedTypeField = getClassField(zombie, 51)
    return getClassFieldVal(zombie, speedTypeField) == 1
end

local function tripZombie(zombie, runner)
    if runner then
        zombie:setBumpType("trippingFromSprint")
    end
end

local function tryRandomTrip(zombie)
    if not SprintersNights_Symptom.tripEnabled then return end
    local md = zombie:getModData()
    if (md.tripCooldown or 0) > 0 then return end
    if zombie:isCrawling() or zombie:isFakeDead() then return end
    local runner = isRunnerZombie(zombie)
    local chance = runner and CHANCE_TRIP_RUNNER_RANDOM or CHANCE_TRIP_SHAMBLER_RANDOM
    if zombie:getTarget() and zombie:isTargetVisible() then
        chance = math.floor(chance * CHASE_MULTIPLIER)
    end
    md.tripCooldown = ZombRand(TICK_MIN, TICK_MAX)
    if ZombRand(100) < chance then
        tripZombie(zombie, runner)
    end
end

local function tryCollisionTrip(zombie)
    if not SprintersNights_Symptom.tripEnabled then return end
    local md = zombie:getModData()
    if (md.tripCooldown or 0) > 0 then return end
    if zombie:isCrawling() or zombie:isFakeDead() then return end
    local runner = isRunnerZombie(zombie)
    local chance = runner and CHANCE_TRIP_RUNNER_COLLIDE or CHANCE_TRIP_SHAMBLER_COLLIDE
    if zombie:getTarget() and zombie:isTargetVisible() then
        chance = math.floor(chance * CHASE_MULTIPLIER)
    end
    md.tripCooldown = ZombRand(TICK_MIN, TICK_MAX)
    if ZombRand(100) < chance then
        tripZombie(zombie, runner)
    end
end

local function OnCharacterCollide(char1, char2)
    if not SprintersNights_Symptom.tripEnabled then return end
    if instanceof(char1, "IsoZombie") and instanceof(char2, "IsoZombie") then
        if char1:isMoving() then
            tryCollisionTrip(char1)
        end
    end
end

local function OnZombieUpdate(zombie)
    if not SprintersNights_Symptom.tripEnabled then return end
    if not zombie:isMoving() then return end
    if zombie:shouldGetUpFromCrawl() or zombie:isKnockedDown() or zombie:isProne() or zombie:isAttacking() then return end
    local md = zombie:getModData()
    md.tripCooldown = (md.tripCooldown or 0) - 1
    if md.tripCooldown < 0 then md.tripCooldown = 0 end
    if (md.tripCooldown or 0) == 0 then
        tryRandomTrip(zombie)
    end
end

Events.OnCharacterCollide.Add(OnCharacterCollide)
Events.OnZombieUpdate.Add(OnZombieUpdate)

--==================================================
--  Atualiza transmissao com base no ícone
--==================================================
local lastX, lastY = nil, nil
local standStillTicks = 0
local STAND_STILL_THRESHOLD = 210  -- 7 segundos
local invisibleActive = false

local function atualizarTransmissaoComBaseNosIcones_Symptom()
    local savedState = ModState.load() or {}
    local icon1 = tostring(savedState.symptomIcon2 or "media/textures/locker.png"):gsub("%s+$", "")

    if icon1 ~= SprintersNights_Symptom.lastIcon1 then
        SprintersNights_Symptom.lastIcon1 = icon1

        local optionspeed = getSandboxOptions():getOptionByName("ZombieLore.Speed")
        local optionHearing = getSandboxOptions():getOptionByName("ZombieLore.Hearing")
        local optionSight = getSandboxOptions():getOptionByName("ZombieLore.Sight")
        local optionToughness = getSandboxOptions():getOptionByName("ZombieLore.Toughness")
        local optionCognition = getSandboxOptions():getOptionByName("ZombieLore.Cognition")
        local optionStrength = getSandboxOptions():getOptionByName("ZombieLore.Strength")

        if icon1 == "media/textures/locker.png" then
            SprintersNights_Symptom.tripEnabled = true
            SprintersNights_Symptom.invisibleEnabled = true
            optionspeed:setValue(1)
            optionHearing:setValue(3)
            optionSight:setValue(1)
            optionToughness:setValue(3)
            optionCognition:setValue(3)
            optionStrength:setValue(3)
            print("tá funfando, tá tudo certo")
        else
            SprintersNights_Symptom.tripEnabled = false
            SprintersNights_Symptom.invisibleEnabled = false
            print("[Transmissao] Novo ícone detectado: " .. icon1)
        end


        if icon1 == "media/textures/Anaerobic_Resuscitation_Icon.png" then
            optionspeed:setValue(3)
            optionHearing:setValue(3)
            optionSight:setValue(3)
            optionToughness:setValue(3)
            optionCognition:setValue(3)
            optionStrength:setValue(3)
            --print("tá funfando, o icone está ligado")
        end


        getSandboxOptions():sendToServer()
    end

    -- Checa se deve ativar invisibilidade
    if SprintersNights_Symptom.invisibleEnabled then
        local player = getPlayer()
        if not player then return end

        local x, y = player:getX(), player:getY()

        if not lastX then
            lastX, lastY = x, y
            return
        end

        if x == lastX and y == lastY then
            standStillTicks = standStillTicks + 1
        else
            standStillTicks = 0
            if invisibleActive then
                player:setInvisible(false)
                invisibleActive = false
            end
        end

        if standStillTicks >= STAND_STILL_THRESHOLD and not invisibleActive then
            player:setInvisible(true)
            invisibleActive = true
            --print("Invisibilidade ativada!")
        end

        lastX, lastY = x, y
    else
        -- garante que invisibilidade desligue quando icon muda
        if invisibleActive then
            local player = getPlayer()
            if player then
                player:setInvisible(false)
                invisibleActive = false
            end
        end
    end
end

if not __transmission_listener_added_symptom then
    Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones_Symptom)
    __transmission_listener_added_symptom = true
end
