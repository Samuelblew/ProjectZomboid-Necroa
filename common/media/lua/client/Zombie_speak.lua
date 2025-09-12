local ModState = require("ModState")

-- Sistema de ícones
local speak = {}
speak.lastIcon1 = nil
speak.enabledNormal = false    -- locker.png
speak.enabledLobotomy = false  -- Anaerobic_Resuscitation_Icon.png

local function atualizarTransmissaoComBaseNosIcones()
    local savedState = ModState.load() or {}
    local icon1 = savedState.symptomIcon2 or "media/textures/locker.png"
    icon1 = tostring(icon1):gsub("%s+$", "")

    if icon1 ~= speak.lastIcon1 then
        speak.lastIcon1 = icon1

        if icon1 == "media/textures/locker.png" then
            print("speak ON")
            speak.enabledNormal = true
            speak.enabledLobotomy = false
        elseif icon1 == "media/textures/Anaerobic_Resuscitation_Icon.png" then
            print("speak LOBOTOMY")
            speak.enabledNormal = false
            speak.enabledLobotomy = true
        else
            print("speak OFF")
            speak.enabledNormal = false
            speak.enabledLobotomy = false
        end
    end
end

Events.OnPlayerUpdate.Add(atualizarTransmissaoComBaseNosIcones)

-- TalkingZeds normal
TalkingZeds = TalkingZeds or {}
local RADIUS_TILES = 30

-- Cooldowns normais
local COOLDOWN_IDLE_H   = 0.03
local COOLDOWN_CHASE_H  = 0.03
local COOLDOWN_HIT_H    = 0.01

-- Cooldowns lobotomia
local COOLDOWN_IDLE_H_LOBO  = 0.06
local COOLDOWN_CHASE_H_LOBO = 0.06
local COOLDOWN_HIT_H_LOBO   = 0.02

local LINES_IDLE = {
    "What have I done...", "I remember screaming...", "Forgive me...", "I can't control it...",
    "I saw their faces...", "Why did I bite...", "It wasn’t me...", "The hunger... it’s me...",
    "I hear them crying...", "I didn’t want this...", "My hands... covered in red...", "I was too late...",
    "I lost myself...",  "I shouldn't have...", "This took me...",
    "I hurted her...", "I can't undo...", "The fear... inside me...", "I can’t stop it...",
    "I am not me...", "Please forget...",  "I can still feel...",
    "I see their eyes...", "It whispers to me...",
    "I can't sleep...", "I remember warmth...", "I feel her scream...", "I betrayed myself...",
    "I didn't choose...", "I see my reflection...", "It's not over... please", "I am empty...",
    "This thing laughs...", "I wander lost...", "I remember a child...",
    "I should have hidden...", "I taste regret...", "I hurt them all...",
    "I didn’t mean it...", "The hunger grows...", "I see shadows move...", "I wanted to hold them...",
    "I can’t forgive...", "I tremble in dark...", "I remember a home...",
    "I am a monster...", "I hurt friends...",
    "I want to cry...", "The disease sings...",  "I see the pain...",
    "I feel cold inside...", "I taste my own fear...", "I am still human...",
    "I should have run...", "I haunt the fields... oh, god",  "I can't rest... please",
    "I remember laughter...", "I feel their faces...", "I wish I could stop...",
    "I scream without voice...", "The disease laughs through me...", "I watch my hands...", "I am not whole...",
    "I remember a garden...", "I stumble...", "I hear their cries...", "I hurt what I loved...",
    "I can't forget...",  "I see the sun fade...", "I whisper to ghosts...",
    "I am lost...", "I remember songs...", "The disease rules...",
    "I cannot sleep...", "I see shadows of myself...", "I wish I were gone...", "I hurt them all..."
}

local LINES_HIT = {
    "It wasn’t me...", "I didn’t mean it!", "Forgive me!", "I hurt again...", 
    "Stop... please...", "I’m sorry...", "No, not like this...", 
    "I feel it...", 
    "Why, GOD?", "Please don’t...", "I didn’t want this!", 
    "It hurts", "No more...", 
    "Stop it...", "I feel the pain...", 
    "It wasn’t my choice...", "I feel shame...", 
    "did i hurt you?", "I am trapped, so don't",
    "I taste blood... my own", "I can’t help it...", "It bites me too...", 
    "I lost control...", "Stop... I beg...", 
    "I’m broken...", "I regret everything...", 
    "No more blood...", "Please forgive me...", 
    "I tremble here...", "I feel it all...", "It’s too late...", 
    "I am ashamed...", "It was me...", 
    "I wish it stopped... but not like this", "I am torn...", 
    "It bites me...",
    "I feel regret...", "I can’t fight...", "It hurts...", 
    "I beg forgiveness...", "I see their pain...", "I cannot control...",
    "I hurt inside...",
    "I hurt too much...", "I cry in vain..."
}

local LINES_CHASE = {
    "I’m sorry...", "Don’t fight me...", "I can’t stop...", "Forgive me...", 
    "It’s not me...", "I see you there...", "I wish I could...", 
    "Don’t hate me...", "I can’t control...", "I hurt again...", 
    "Please forgive...", "I see...", "I scream inside...", "I can’t stop this...", 
    "I see fear...", "I feel shame...", "I am broken...",
    "I regret...", "I see pain...", "I feel horror...", "I tremble inside...", 
    "I chase with guilt...", "I am trapped...", "I see nothing...", "I can’t forgive myself", 
    "I hurt inside...", "I regret still...",  "I chase with grief...",  "I chase, I sigh...",  "I feel guilt...", 
    "I see regret...", "I chase in grief...", "I hurt... it is not me", "I chase in vain..."
}

-- Novas linhas "lobotomia" (curtas e raras)
local LINES_IDLE_LOBO = { "Huh...", "Me?", "No...", "Ah...", "D-Daughter", "S-Son" }
local LINES_HIT_LOBO  = { "Ow...", "Ah!", "No..." }
local LINES_CHASE_LOBO = { "Run...", "Go...", "don oo bac..." }

local function nowHours() return getGameTime():getWorldAgeHours() end
local function inRange(z, p, tiles) return z:DistToProper(p) <= tiles end
local function pick(list) return list[ZombRand(#list) + 1] end
local function sayOncePer(z, key, cooldownHrs, lineList)
    if not z or not z:isAlive() then return end
    local md = z:getModData()
    md.TalkingZeds = md.TalkingZeds or {}
    local t = nowHours()
    local last = md.TalkingZeds[key] or 0
    if t - last < cooldownHrs then return end
    md.TalkingZeds[key] = t
    z:addLineChatElement(pick(lineList))
end

-- Handler único que checa os modos
local function onZombieUpdate(z)
    local player = getPlayer()
    if not player or not z or not z:isAlive() then return end
    if not inRange(z, player, RADIUS_TILES) then return end
    local target = z:getTarget()

    -- Modo normal
    if speak.enabledNormal then
        if target == player then
            if ZombRand(100) < 4 then
                sayOncePer(z, "lastChase", COOLDOWN_CHASE_H, LINES_CHASE)
            end
        elseif target == nil then
            if ZombRand(1000) < 2 then
                sayOncePer(z, "lastIdle", COOLDOWN_IDLE_H, LINES_IDLE)
            end
        end
    end

    -- Modo lobotomia
    if speak.enabledLobotomy then
        if target == player then
            if ZombRand(100) < 2 then  -- mais raro
                sayOncePer(z, "lastChaseLobo", COOLDOWN_CHASE_H_LOBO, LINES_CHASE_LOBO)
            end
        elseif target == nil then
            if ZombRand(1000) < 1 then  -- super raro
                sayOncePer(z, "lastIdleLobo", COOLDOWN_IDLE_H_LOBO, LINES_IDLE_LOBO)
            end
        end
    end
end

local function onWeaponHitCharacter(attacker, target, weapon, damage)
    if not target or not instanceof(target, "IsoZombie") or not target:isAlive() then return end
    if not inRange(target, getPlayer(), RADIUS_TILES + 10) then return end

    if speak.enabledNormal then
        sayOncePer(target, "lastHit", COOLDOWN_HIT_H, LINES_HIT)
    elseif speak.enabledLobotomy then
        if ZombRand(100) < 50 then  -- chance menor de reagir
            sayOncePer(target, "lastHitLobo", COOLDOWN_HIT_H_LOBO, LINES_HIT_LOBO)
        end
    end
end

Events.OnZombieUpdate.Add(onZombieUpdate)
Events.OnWeaponHitCharacter.Add(onWeaponHitCharacter)

Events.OnGameStart.Add(function()
    print("[TalkingZeds] loaded (radius=" .. tostring(RADIUS_TILES) .. " tiles)")
end)
