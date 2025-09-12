BloodInfection = BloodInfection or {}
local ModState = require("ModState")

function BloodInfection.getWornBloodLevel()
    local player = getPlayer()
    if not player then return 0 end

    local wornItems = player:getWornItems()
    if not wornItems or wornItems:isEmpty() then return 0 end

    -- Check for Hazmat Suit and exit if found
    for i = 0, wornItems:size() - 1 do
        local entry = wornItems:get(i)
        local item = entry and entry:getItem()
        if item then
            local fullType = item:getFullType()
            if fullType == "Base.HazmatSuit" then
                print("[BloodInfection] Hazmat Suit detected — exiting worn blood check.")
                return 0
            end
        end
    end

    -- Continue as normal if no Hazmat Suit
    local itemBlood = 0
    local wornCount = 0
    for i = 0, wornItems:size() - 1 do
        local clothing = wornItems:getItemByIndex(i)
        if instanceof(clothing, "Clothing") then
            if clothing:getBloodClothingType() ~= nil then
                local currentItemBlood = clothing:getBloodLevel() or 0
                if currentItemBlood > 0 then
                    wornCount = wornCount + 1
                    itemBlood = itemBlood + currentItemBlood
                end
            end
        end
    end

    if wornCount > 0 then
        return round(itemBlood / wornCount)
    end

    return 0
end




function BloodInfection.getBodyBloodLevel()
    local pl = getPlayer()
    local vis = pl:getHumanVisual()
    local level = 0
    local maxLevel = BloodBodyPartType.MAX:index()

    for i = 0, maxLevel - 1 do
        local bloodLevel = tonumber(vis:getBlood(BloodBodyPartType.FromIndex(i)))
        level = level + bloodLevel
    end

    if level > 0 then
        local res = (level / maxLevel) * 100
        return round(tonumber(res))
    end
    return 0
end

function BloodInfection.getTotalBloodLevel()
    local pl = getPlayer()
    local wornLvl = BloodInfection.getWornBloodLevel()
    local bodyLvl = BloodInfection.getBodyBloodLevel()
    if wornLvl == 0 then
        return round(bodyLvl)
    elseif bodyLvl == 0 then
        return round(wornLvl)
    else
        local res = (wornLvl + bodyLvl) / 2
        return round(res)
    end
end

-------------------------------------------------------------
-- Make player say how bloody they are
-------------------------------------------------------------
function BloodInfection.sayBloodLevel()
    local player = getPlayer()
    local level = BloodInfection.getTotalBloodLevel()

    if level > 0 then
        print("[BloodInfection] Player blood level: " .. level .. "%")
    else
        player:Say("I'm clean. No blood on me.")
        print("[BloodInfection] Player is clean.")
    end
end


function BloodInfection.checkBloodInfection()
    local savedState = ModState.load() or {}
    local player = getPlayer()
    if not player then return end

    local icon1 = savedState.infectionIcon9 or "media/textures/locker.png"
    local icon2 = savedState.infectionIcon10 or "media/textures/locker.png"
    local bloodLevel = BloodInfection.getTotalBloodLevel()

    -- ========================
    -- PRIORIDADE: Icone 2 (Preto)
    -- ========================
    if icon2 == "media/textures/Blood_Icon2.png" then
        if bloodLevel >= 40 then
            player:getBodyDamage():setInfected(true)
            print(string.format("[BloodInfection] Infecção severa ativada! Nível de sangue (%.2f%%) ≥ 20%%", bloodLevel))
        else
            print(string.format("[BloodInfection] Seguro: Nível de sangue (%.2f%%) < 20%%", bloodLevel))
        end
        return
    end

    -- ========================
    -- Icone 1 (blood 1)
    -- ========================
    if icon1 == "media/textures/Blood_Icon.png" then
        if bloodLevel >= 60 then
            player:getBodyDamage():setInfected(true)
            print(string.format("[BloodInfection] Infecção leve ativada! Nível de sangue (%.2f%%) ≥ 40%%", bloodLevel))
        else
            print(string.format("[BloodInfection] Seguro: Nível de sangue (%.2f%%) < 40%%", bloodLevel))
        end
        return
    end

    -- ========================
    -- Nenhum ícone ativo
    -- ========================
    print("[BloodInfection] Nenhum ícone de infecção ativo — seguro.")
end

-------------------------------------------------------------
-- Say stuff
-------------------------------------------------------------
do
    local startTime = nil
    local delaySeconds = 300
    local lastSpeakTime = 0

    function BloodInfection.sayWornClothingBloodLevel()
        local player = getPlayer()
        if not player then return end

        local currentTime = os.time()
        if not startTime then
            startTime = currentTime
            lastSpeakTime = currentTime - delaySeconds -- pra falar logo na primeira checagem
        end

        local elapsedSinceLastSpeak = currentTime - lastSpeakTime

        if elapsedSinceLastSpeak < delaySeconds then
            return -- ainda esperando
        end

        lastSpeakTime = currentTime

        local wornItems = player:getWornItems()
        if not wornItems or wornItems:isEmpty() then
         return
        end

        local itemBlood = 0
        local wornCount = 0

        for i = 0, wornItems:size() - 1 do
        local entry = wornItems:get(i)
        local item = entry and entry:getItem()
        if item then
            local fullType = item:getFullType()
            if fullType == "Base.HazmatSuit" then
                return 0
            end
        end
     end

        for i = 0, wornItems:size() - 1 do
            local clothing = wornItems:getItemByIndex(i)
            if instanceof(clothing, "Clothing") then
                if clothing:getBloodClothingType() ~= nil then
                    local currentItemBlood = clothing:getBloodLevel() or 0
                    if currentItemBlood > 0 then
                        wornCount = wornCount + 1
                        itemBlood = itemBlood + currentItemBlood
                    end
                end
            end
        end

        local avgLevel = 0
        if wornCount > 0 then
            avgLevel = math.floor((itemBlood / wornCount) + 0.5)
        end

        

        if avgLevel <= 0 then
            player:Say("")
        elseif avgLevel <= 5 then
            player:Say("i don't like the blood on my clothes")
        elseif avgLevel <= 15 then
            player:Say("i need to wash my clothes")
        elseif avgLevel <= 30 then
            player:Say("I have a bad feelng about the amount of blood on me")
        elseif avgLevel <= 50 then
            player:Say("There's way too much blood on me")
        elseif avgLevel <= 75 then
            player:Say("I'm drenched... blood everywhere.")
        elseif avgLevel <= 90 then
            player:Say("it smells like death, and maybe it is mine")
        else
            player:Say("I'm completely covered in blood...")
        end
    end
end

Events.OnPlayerUpdate.Add(function(player)
    if player:getPlayerNum() == 0 then
        BloodInfection.sayWornClothingBloodLevel()
    end
end)

-------------------------------------------------------------
-- end of it
-------------------------------------------------------------



