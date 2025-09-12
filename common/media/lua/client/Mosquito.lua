local ModState = require("ModState")
local savedState = ModState.load() or {}
local icon = savedState.infectionIcon6 or "media/textures/locker.png"

-- Helper function to check if infection should occur
local function shouldInfect()
    local state = ModState.load() or {}
    print("[CorpseExpose] Checking icon:", state.infectionIcon6)
    return state.infectionIcon6 == "media/textures/Insect_Icon.png"
end

if icon == "media/textures/Insect_Icon.png" then
    
    function InitCorpseInfectionSystem()
        --------------------------------------------------------------
        --   INFECÇÃO POR CADÁVER – tempo real
        --   • Só conta se o cadáver tiver moscas (≥ 72 h morto)
        --   • Infecta após 3 min REAIS de exposição contínua
        --   • Proteção baseada nas roupas vestidas (5 partes)
        --------------------------------------------------------------

        local corpseTimers           = {}
        local deathTimeField         = nil
        local INFECT_AFTER_SECONDS   = 180
        local FLIES_THRESHOLD_HOURS  = 72
        local CHECK_RADIUS           = 3

        string.trim = function(s)
            return s:match("^%s*(.-)%s*$")
        end

        local function isCorpseValid(player, corpse, distance, playerIsOutside)
            if player:getZ() ~= corpse:getZ() then return false end
            if corpse:isSkeleton() then return false end

            if not deathTimeField then
                for f = 0, getNumClassFields(corpse)-1 do
                    local fld = getClassField(corpse, f)
                    if tostring(fld):find("deathTime$") then
                        deathTimeField = fld
                        break
                    end
                end
            end
            if not deathTimeField then return false end

            local worldHrs = getGameTime():getWorldAgeHours()
            local deathHrs = getClassFieldVal(corpse, deathTimeField)
            if not deathHrs then return false end
            if worldHrs - deathHrs < FLIES_THRESHOLD_HOURS then return false end

            local corpseSq = corpse:getSquare()
            if not corpseSq then return false end
            if playerIsOutside ~= corpseSq:isOutside() and distance > 2 then return false end
            if not player:CanSee(corpse) then return false end
            return true
        end

        local function playerNearCorpse(player)
            local sq = player:getSquare()
            if not sq then return false end
            local cell = getCell()
            local px, py, pz = sq:getX(), sq:getY(), sq:getZ()
            local isOutside = player:isOutside()

            for dx = -CHECK_RADIUS, CHECK_RADIUS do
                for dy = -CHECK_RADIUS, CHECK_RADIUS do
                    local gs = cell:getGridSquare(px + dx, py + dy, pz)
                    if gs then
                        local corpses = gs:getDeadBodys()
                        for i = 0, corpses:size() - 1 do
                            local corpse = corpses:get(i)
                            if corpse then
                                local dist = player:DistTo(corpse)
                                if isCorpseValid(player, corpse, dist, isOutside) then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
            return false
        end

        local function startTimer(id)
            corpseTimers[id] = {
                startTime = getTimestampMs(),
                lastPrintSec = -1,
            }
        end

        local function stopTimer(id)
            corpseTimers[id] = nil
        end

        local function elapsedSec(id)
            if corpseTimers[id] then
                return (getTimestampMs() - corpseTimers[id].startTime) / 1000
            end
            return 0
        end

        local function onPlayerUpdate(player)
            if not player or player:isDead() then return end
            local id = player:getPlayerNum()
            if not id then return end

            if player:getBodyDamage():isInfected() then
                if corpseTimers[id] then
                    stopTimer(id)
                    print(string.format("[CorpseExpose] Jog %d já infectado: cronômetro parado", id))
                end
                return
            end

            if playerNearCorpse(player) then
                if not corpseTimers[id] then
                    startTimer(id)
                    print(string.format("[CorpseExpose] Jog %d: cronômetro iniciado (moscas detectadas)", id))
                else
                    local t = elapsedSec(id)
                    local currentPrintSec = math.floor(t / 5) * 5
                    if corpseTimers[id].lastPrintSec ~= currentPrintSec then
                        corpseTimers[id].lastPrintSec = currentPrintSec
                        print(string.format("[CorpseExpose] Jog %d exposto %.0fs", id, t))
                    end

                    if t >= INFECT_AFTER_SECONDS then
                        stopTimer(id)
                        local infectionChance = 0.12
                        player:Say(string.format("Chance fixa de infecção: %.0f%%", infectionChance * 100))
                        print(string.format("[CorpseExpose] Jog %d chance fixa: %.0f%%", id, infectionChance * 100))

                        if shouldInfect() then
                            if ZombRandFloat(0.0, 1.0) < infectionChance then
                                player:getBodyDamage():setInfected(true)
                                player:Say("Você foi infectado por ficar perto de um cadáver com moscas!")
                                print(string.format("[CorpseExpose] Jog %d INFECTADO", id))
                            else
                                player:Say("Você resistiu à infecção.")
                                print(string.format("[CorpseExpose] Jog %d NÃO infectado", id))
                            end
                        else
                            print("[CorpseExpose] Icon changed, not infecting.")
                        end
                    end
                end
            else
                if corpseTimers[id] then
                    stopTimer(id)
                    print(string.format("[CorpseExpose] Jog %d se afastou. Cronômetro resetado.", id))
                end
            end
        end

        Events.OnPlayerUpdate.Add(onPlayerUpdate)
    end

    -- Chama a função para ativar o sistema
    InitCorpseInfectionSystem()
else
    print("[CorpseExpose] Ícone incompatível — sistema de infecção por cadáver não carregado.")
end
