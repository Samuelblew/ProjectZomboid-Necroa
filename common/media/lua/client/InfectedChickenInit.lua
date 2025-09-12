local ModState = require("ModState")

----------------------------------------------------------------
-- Roda uma vez, assim que os scripts Lua do jogo são carregados
----------------------------------------------------------------
Events.OnGameBoot.Add(function()
    local sm = ScriptManager.instance
    if not sm then return end

    local itemsToModify = {
        "Base.Chicken",
        "Base.ChickenWings",
        "Base.ChickenFillet",
        "Base.ChickenWhole",
        "Base.Smallbirdmeat",
        "Base.DeadBird",
        "Base.ChickenFoot",
        "Base.Egg",
        "Base.TurkeyWhole",
        "Base.TurkeyEgg",
        "Base.TurkeyFillet",
        "Base.TurkeyLegs",
        "Base.TurkeyWings",
    }

    for _, itemName in ipairs(itemsToModify) do
        local item = sm:getItem(itemName)
        if item then
            item:DoParam("OnEat = InfectedChicken_OnEatUnified")
            print("[InfectedChickenMod] Hooked OnEatUnified to: " .. itemName)
        else
            print("[InfectedChickenMod] Item not found: " .. itemName)
        end
    end
end)

----------------------------------------------------------------
-- Única função que trata os dois modos de infecção
----------------------------------------------------------------
function InfectedChicken_OnEatUnified(food, player)
    if not player then return end

    local savedState = ModState.load() or {}
    local icon1 = savedState.infectionIcon1 or "media/textures/locker.png"
    local icon2 = savedState.infectionIcon2 or "media/textures/locker.png"

    -- ========================
    -- PRIORIDADE: Icone 2 (Preto)
    -- ========================
    if icon2 == "media/textures/Bird_Iconblack.png" then
        print("[InfectedChickenMod] Icon 2 (Bird_Iconblack) ativo — modo severo")

        if food:isCooked() then
            local chance = ZombRandFloat(0, 1)
            if chance <= 0.12 then
                print(string.format("[InfectedChickenMod] Cozida/queimada — sobreviveu (%.2f ≤ 0.12)", chance))
                return
            else
                print(string.format("[InfectedChickenMod] Cozida/queimada — infectado (%.2f > 0.12)", chance))
            end
        else
            print("[InfectedChickenMod] Crua — infecção garantida (modo severo)")
        end

        -- Infecta (modo severo)
        local body = player:getBodyDamage()
        body:setInfected(true)
        print("[InfectedChickenMod] INFECÇÃO severa aplicada pelo ícone 2")
        return
    end

    -- ========================
    -- Icone 1 (Pássaro branco)
    -- ========================
    if icon1 == "media/textures/Bird_Icon.png" then
        print("[InfectedChickenMod] Icon 1 (Bird_Icon) ativo — modo leve")

        if food:isCooked() then
            local chance = ZombRandFloat(0, 1)
            if chance <= 0.78 then
                print(string.format("[InfectedChickenMod] Cozida/queimada — sobreviveu (%.2f ≤ 0.78)", chance))
                return
            else
                print(string.format("[InfectedChickenMod] Cozida/queimada — infectado (%.2f > 0.78)", chance))
            end
        else
            print("[InfectedChickenMod] Crua — infecção garantida (modo leve)")
        end

        -- Infecta (modo leve)
        local body = player:getBodyDamage()
        body:setInfected(true)
        print("[InfectedChickenMod] INFECÇÃO leve aplicada pelo ícone 1")
        return
    end

    print("[InfectedChickenMod] Nenhum ícone de infecção ativo — seguro.")
end
