-- =================================================================
-- AbilitiesEngine.lua (Atualizado com gatilho EveryDays)
-- Controla a progressão diária das HABILIDADES no ModState.
-- =================================================================
local AbilitiesEngine = {}

-- Ativa prints de debug (true para ligar, false para desligar)
local DEBUG_LOG = true

local ModState = require("ModState")

-- 1. A ÁRVORE DE HABILIDADES (AQUI VOCÊ DEFINE A PROGRESSÃO)
-- IMPORTANTE: A árvore de dependências abaixo é um EXEMPLO.
-- Você PRECISA editar o 'dependsOn' para definir a progressão que você quer!
local ABILITIES_TREE = {
   { id = 1,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HI.png",              dependsOn = nil },
    { id = 9,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HP.png",              dependsOn = 8 },
    { id = 25, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HR1.png",             dependsOn = nil },
    { id = 2,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/ST.png",              dependsOn = 1 },
    { id = 3,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DM.png",              dependsOn = 2 },
    { id = 7,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HI1.png",             dependsOn = 2 },
    { id = 10, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DR.png",              dependsOn = nil },
    { id = 19, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DR1.png",             dependsOn = nil },
    { id = 24, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HR2.png",             dependsOn = 7 },
    { id = 26, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Mummification.png",   dependsOn = 25 },
    { id = 4,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DF.png",              dependsOn = 3 },
    { id = 5,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Echopraxia.png",    dependsOn = 3 },
    { id = 8,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/HV.png",              dependsOn = 7 },
    { id = 11, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/PR.png",              dependsOn = 10 },
    { id = 20, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DR2.png",             dependsOn = 19 },
    { id = 27, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/CR1.png",             dependsOn = nil },
    { id = 6,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/EQ.png",              dependsOn = 5 },
    { id = 12, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/LR.png",              dependsOn = 11 },
    { id = 18, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/CM.png",              dependsOn = 17 },
    { id = 21, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/GH.png",              dependsOn = 10 },
    { id = 28, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/CR2.png",             dependsOn = 27 },
    { id = 15, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/LN.png",              dependsOn = 14 },
    { id = 17, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/ED.png",              dependsOn = 16 },
    { id = 14, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/AP.png",              dependsOn = 13 },
    { id = 16, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/RB.png",              dependsOn = 13 },
    { id = 13, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/RA.png",              dependsOn = nil },
    { id = 22, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/GR1.png",             dependsOn = 19 },
    { id = 23, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/GR2.png",             dependsOn = 22 },
}

-- Função auxiliar para checar se uma dependência está ATIVA
local function isDependencyActive(dependencyId, savedState)
    if not dependencyId then return true end
    local dependencyKey = "abilityIcon" .. dependencyId -- Chave alterada para 'abilityIcon'
    local dependencyValue = savedState[dependencyKey]
    return dependencyValue and dependencyValue ~= "media/textures/locker.png"
end

-- 2. A FUNÇÃO PRINCIPAL (Adaptada para habilidades)
function AbilitiesEngine.updateProgression()
    if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] updateProgression() chamado.") end
    local savedState = ModState.load() or {}

    if not savedState.abilitiesEngineInitialized then
        if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] Inicializando: desbloqueando habilidades iniciais.") end
        for _, node in ipairs(ABILITIES_TREE) do
            if not node.dependsOn then
                savedState["abilityIcon" .. node.id] = node.baseTexture
            end
        end
        savedState.abilitiesEngineInitialized = true
        ModState.save(savedState)
        if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] Inicialização salva no ModState.") end
        return
    end

    -- PRIORIDADE 1: Tentar ATIVAR uma habilidade que está inativa ("locker").
    for _, node in ipairs(ABILITIES_TREE) do
        local iconKey = "abilityIcon" .. node.id
        if savedState[iconKey] and savedState[iconKey] == node.baseTexture then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[AbilitiesEngine] ATIVANDO habilidade existente: ID " .. node.id)
                savedState[iconKey] = node.activeTexture
                ModState.save(savedState)
                return
            end
        end
    end

    -- PRIORIDADE 2: Se não ativou ninguém, tentar DESBLOQUEAR uma nova habilidade.
    for _, node in ipairs(ABILITIES_TREE) do
        local iconKey = "abilityIcon" .. node.id
        if not savedState[iconKey] then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[AbilitiesEngine] DESBLOQUEANDO nova habilidade: ID " .. node.id)
                savedState[iconKey] = node.baseTexture
                ModState.save(savedState)
                return
            end
        end
    end
    
    if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] Nenhuma evolução de habilidade hoje.") end
end

-- 3. GATILHO: rodar UMA VEZ por dia de jogo usando Events.EveryDays (Seu método)
local function onDayTick()
    if not getPlayer() then
        if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] onDayTick: getPlayer() == nil. Ignorando.") end
        return
    end

    local gt = getGameTime()
    if not gt then
        if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] onDayTick: getGameTime() == nil. Ignorando.") end
        return
    end

    local ok, day = pcall(function() return gt:getDay() end)
    if not ok or not day then
        if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] onDayTick: gt:getDay() falhou ou retornou nil. Ignorando.") end
        return
    end
    
    if DEBUG_LOG then
        print(string.format("[AbilitiesEngine][DAY_TICK] Dia do jogo: %d — executando progressão de habilidades.", day))
    end

    AbilitiesEngine.updateProgression()
end

-- Registra o EveryDays SOMENTE quando o jogo inicia (evita hooks prematuros)
Events.OnGameStart.Add(function()
    if DEBUG_LOG then print("[AbilitiesEngine][DEBUG] OnGameStart: registrando Events.EveryDays.") end
    Events.EveryDays.Add(onDayTick)
end)

return AbilitiesEngine