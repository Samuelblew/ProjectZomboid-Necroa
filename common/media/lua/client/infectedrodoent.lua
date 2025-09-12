local ModState = require("ModState")

----------------------------------------------------------------
-- Roda uma vez, assim que os scripts Lua do jogo são carregados
----------------------------------------------------------------
Events.OnGameBoot.Add(function()
    local sm = ScriptManager.instance
    if not sm then return end

    local rodentItems = {
        "Base.DeadMouse",
        "Base.DeadRabbit",
        "Base.DeadRat",
        "Base.deadSquirrel",
        "Base.DeadMousePups",
        "Base.DeadRatBaby",
        "Base.Smallanimalmeat",
        "Base.DeadMouseSkinned",
        "Base.DeadMousePupsSkinned",
        "Base.DeadRatSkinned",
        "Base.DeadRatBabySkinned",
        "Base.Rabbitmeat",
    }

    for _, itemName in ipairs(rodentItems) do
        local item = sm:getItem(itemName)
        if item then
            item:DoParam("OnEat = InfectedRodent_OnEat")
            print("[InfectedRodentMod] Hooked OnEat to: " .. itemName)
        else
            print("[InfectedRodentMod] Item not found: " .. itemName)
        end
    end
end)

----------------------------------------------------------------
-- Chamado automaticamente quando qualquer carne de roedor é comida
----------------------------------------------------------------
function InfectedRodent_OnEat(food, player)
    if not player then return end

    local savedState = ModState.load() or {}
    local icon1 = savedState.infectionIcon4 or "media/textures/locker.png"
    local icon2 = savedState.infectionIcon5 or "media/textures/locker.png"

    -- Se o ícone 2 (preto) estiver ativo, ele tem prioridade
    if icon2 == "media/textures/Rodent_Iconblack.png" then
        -- Se estiver cozido, chance de escapar é menor
        if food:isCooked() then
            local chance = ZombRandFloat(0, 1)
            if chance <= 0.12 then
                print(string.format("[InfectedRodentMod] Rodent Icon 2 active — survived cooked (%.2f ≤ 0.12)", chance))
                return
            else
                print(string.format("[InfectedRodentMod] Rodent Icon 2 active — infected (%.2f > 0.12)", chance))
            end
        else
            print("[InfectedRodentMod] Rodent Icon 2 active — raw rodent = guaranteed infection.")
        end

        -- Infecta
        local body = player:getBodyDamage()
        body:setInfected(true)
        print("[InfectedRodentMod] Player infected by icon 2 logic.")
        return
    end

    -- Caso o ícone 1 (normal) esteja ativo
    if icon1 == "media/textures/Rodent_Icon.png" then
        if food:isCooked() then
            local chance = ZombRandFloat(0, 1)
            if chance <= 0.78 then
                print(string.format("[InfectedRodentMod] Icon 1 — cooked rodent survived (%.2f ≤ 0.78)", chance))
                return
            else
                print(string.format("[InfectedRodentMod] Icon 1 — cooked rodent infected (%.2f > 0.78)", chance))
            end
        else
            print("[InfectedRodentMod] Icon 1 — raw rodent = guaranteed infection.")
        end

        -- Infecta
        local body = player:getBodyDamage()
        body:setInfected(true)
        print("[InfectedRodentMod] Player infected by icon 1 logic.")
        return
    end

    -- Se nenhum ícone estiver ativo
    print("[InfectedRodentMod] No relevant infection icon active — no infection.")
end
