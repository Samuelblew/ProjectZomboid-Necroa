-- =================================================================
-- InfectionEngine.lua (v3 - Triggered once per in-game day) + DEBUG prints
-- Controla a progressão, priorizando ativar ícones inativos
-- antes de desbloquear novos ícones na árvore.
-- =================================================================
local InfectionEngine = {}

-- Ativa prints de debug (true para ligar, false para desligar)
local DEBUG_LOG = true

local ModState = require("ModState")

local INFECTION_TREE = {
    { id = 1,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Bird_Icon.png",       dependsOn = 3 },
    { id = 2,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Bird_Iconblack.png", dependsOn = 1 },
    { id = 3,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Zoonotic_Icon.png",  dependsOn = nil },
    { id = 4,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Rodent_Icon.png",     dependsOn = 3 },
    { id = 5,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Rodent_Iconblack.png", dependsOn = 4 },
    { id = 6,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Insect_Icon.png",   dependsOn = 3 },
    { id = 7,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Bat_Icon.png",        dependsOn = 3 },
    { id = 8,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Bat_Iconblack.png",   dependsOn = 7 },
    { id = 9,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Blood_Icon.png",      dependsOn = nil },
    { id = 10, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Blood_Icon2.png",     dependsOn = 9 },
    { id = 11, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Air_Icon.png",        dependsOn = 9 },
    { id = 12, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Air_Icon2.png",       dependsOn = 11 },
    { id = 13, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Air_Icon3.png",       dependsOn = 12 },
    { id = 14, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Urogenital_Icon.png", dependsOn = 15 },
    { id = 15, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Saliva_Icon.png",     dependsOn = nil },
    { id = 16, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Saliva_Icon2.png",    dependsOn = 15 },
    { id = 17, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Nausea_Icon.png",     dependsOn = 15 },
    { id = 18, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Water_Icon.png",      dependsOn = 15 },
    { id = 19, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Water_Icon2.png",     dependsOn = 18 },
    { id = 20, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Genome_Icon.png",     dependsOn = 10 },
}

-- Função auxiliar para checar se uma dependência está ATIVA
local function isDependencyActive(dependencyId, savedState)
    if not dependencyId then return true end -- Sem dependência = OK
    local dependencyKey = "infectionIcon" .. dependencyId
    local dependencyValue = savedState[dependencyKey]
    return dependencyValue and dependencyValue ~= "media/textures/locker.png"
end

-- 2. A FUNÇÃO PRINCIPAL (Lógica final com prioridades)
function InfectionEngine.updateProgression()
    if DEBUG_LOG then print("[InfectionEngine][DEBUG] updateProgression() chamado.") end
    local savedState = ModState.load() or {}

    -- Inicialização: No dia 0, DESBLOQUEIA (não ativa) os 3 iniciais.
    if not savedState.infectionEngineInitialized then
        if DEBUG_LOG then print("[InfectionEngine][DEBUG] Inicializando: desbloqueando ícones 3,9,15 como baseTexture.") end
        savedState["infectionIcon3"] = INFECTION_TREE[3].baseTexture
        savedState["infectionIcon9"] = INFECTION_TREE[9].baseTexture
        savedState["infectionIcon15"] = INFECTION_TREE[15].baseTexture
        savedState.infectionEngineInitialized = true
        ModState.save(savedState)
        if DEBUG_LOG then print("[InfectionEngine][DEBUG] Inicialização salva no ModState.") end
        return
    end

    -- PRIORIDADE 1: Tentar ATIVAR um ícone que está inativo ("locker").
    for _, node in ipairs(INFECTION_TREE) do
        local iconKey = "infectionIcon" .. node.id
        if savedState[iconKey] and savedState[iconKey] == node.baseTexture then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[InfectionEngine] ATIVANDO ícone existente: ID " .. node.id)
                savedState[iconKey] = node.activeTexture
                ModState.save(savedState)
                if DEBUG_LOG then print("[InfectionEngine][DEBUG] Ativação salva: " .. iconKey .. " -> " .. node.activeTexture) end
                return -- Ação do dia concluída.
            else
                if DEBUG_LOG then
                    print("[InfectionEngine][DEBUG] Ícone " .. node.id .. " está desbloqueado mas dependência NÃO ativa.")
                end
            end
        end
    end

    -- PRIORIDADE 2: Se não ativou ninguém, tentar DESBLOQUEAR um novo ícone.
    for _, node in ipairs(INFECTION_TREE) do
        local iconKey = "infectionIcon" .. node.id
        if not savedState[iconKey] then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[InfectionEngine] DESBLOQUEANDO novo ícone: ID " .. node.id)
                savedState[iconKey] = node.baseTexture -- Adiciona como "locker"
                ModState.save(savedState)
                if DEBUG_LOG then print("[InfectionEngine][DEBUG] Desbloqueio salvo: " .. iconKey .. " -> " .. node.baseTexture) end
                return -- Ação do dia concluída.
            else
                if DEBUG_LOG then
                    print("[InfectionEngine][DEBUG] Não pode desbloquear " .. node.id .. " — dependência não ativa.")
                end
            end
        end
    end

    if DEBUG_LOG then print("[InfectionEngine][DEBUG] Nenhuma evolução hoje.") end
end

-- 3. GATILHO: rodar UMA VEZ por dia de jogo usando Events.EveryDays
local function onDayTick()
    -- Garantias básicas
    if not getPlayer() then
        if DEBUG_LOG then print("[InfectionEngine][DEBUG] onDayTick: getPlayer() == nil. Ignorando.") end
        return
    end

    local gt = getGameTime()
    if not gt then
        if DEBUG_LOG then print("[InfectionEngine][DEBUG] onDayTick: getGameTime() == nil. Ignorando.") end
        return
    end

    -- Usa pcall para proteger caso getDay falhe em algum contexto
    local ok, day = pcall(function() return gt:getDay() end)
    if not ok or not day then
        if DEBUG_LOG then print("[InfectionEngine][DEBUG] onDayTick: gt:getDay() falhou ou retornou nil. Ignorando.") end
        return
    end

    if DEBUG_LOG then
        print(string.format("[InfectionEngine][DAY_TICK] Dia do jogo: %d — executando progressão diária.", day))
    else
        print("[InfectionEngine] Dia passado — executando progressão diária.")
    end

    InfectionEngine.updateProgression()
    if DEBUG_LOG then print("[InfectionEngine][DAY_TICK] updateProgression() finalizou para o dia " .. tostring(day)) end
end

-- Registra o EveryDays SOMENTE quando o jogo inicia (evita hooks prematuros)
Events.OnGameStart.Add(function()
    if DEBUG_LOG then print("[InfectionEngine][DEBUG] OnGameStart: registrando Events.EveryDays.") end
    Events.EveryDays.Add(onDayTick)
    -- Opcional: chamar updateProgression() aqui para teste sem esperar o próximo dia
    -- InfectionEngine.updateProgression()
end)

return InfectionEngine
