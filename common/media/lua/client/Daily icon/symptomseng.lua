-- =================================================================
-- SymptomEngine.lua (Baseado no seu código)
-- Controla a progressão diária dos SINTOMAS no ModState.
-- =================================================================
local SymptomEngine = {}

-- Ativa prints de debug (true para ligar, false para desligar)
local DEBUG_LOG = true

local ModState = require("ModState")

-- 1. A ÁRVORE DE SINTOMAS (Ícones 1-20)
-- IMPORTANTE: A árvore de dependências abaixo é um EXEMPLO.
-- Você PRECISA editar o 'dependsOn' para definir a progressão que você quer!
local SYMPTOM_TREE = {
    { id = 1,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Cytopathic_Reanimation_Icon.png", dependsOn = nil },
    { id = 2,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Anaerobic_Resuscitation_Icon.png", dependsOn = 1 },
    { id = 20, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Psychosis.png", 				  dependsOn = nil },
    { id = 3,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/EMC.png", 						  dependsOn = 2 },
    { id = 4,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/PS.png", 						  dependsOn = 3 },
    { id = 15, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/ES.png", 						  dependsOn = 2 },
    { id = 18, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/CS.png", 						  dependsOn = 17 },
    { id = 19, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/VH.png", 						  dependsOn = 18 },
    { id = 5,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/DC.png", 						  dependsOn = 4 },
    { id = 6,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/AR.png", 						  dependsOn = 4 },
    { id = 9,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/CE.png", 						  dependsOn = 5 },
    { id = 16, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Hyperosmia.png", 			  dependsOn = 15 },
    { id = 17, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/TL.png", 						  dependsOn = 15 },
    { id = 7,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/NM.png", 						  dependsOn = 6 },
    { id = 10, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/BD.png", 						  dependsOn = 9 },
    { id = 8,  baseTexture = "media/textures/locker.png", activeTexture = "media/textures/Autothysis.png", 				  dependsOn = 7 },
    { id = 14, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/AS.png", 						  dependsOn = 15 },
    { id = 11, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/MT.png", 						  dependsOn = 3 },
    { id = 13, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/LH.png", 						  dependsOn = 14 },
    { id = 12, baseTexture = "media/textures/locker.png", activeTexture = "media/textures/AB.png", 						  dependsOn = 3 },
}

-- Função auxiliar para checar se uma dependência está ATIVA
local function isDependencyActive(dependencyId, savedState)
    if not dependencyId then return true end
    local dependencyKey = "symptomIcon" .. dependencyId -- Chave alterada para 'symptomIcon'
    local dependencyValue = savedState[dependencyKey]
    return dependencyValue and dependencyValue ~= "media/textures/locker.png"
end

-- 2. A FUNÇÃO PRINCIPAL (Adaptada para sintomas)
function SymptomEngine.updateProgression()
    if DEBUG_LOG then print("[SymptomEngine][DEBUG] updateProgression() chamado.") end
    local savedState = ModState.load() or {}

    if not savedState.symptomEngineInitialized then
        if DEBUG_LOG then print("[SymptomEngine][DEBUG] Inicializando: desbloqueando sintomas iniciais.") end
        for _, node in ipairs(SYMPTOM_TREE) do
            if not node.dependsOn then
                savedState["symptomIcon" .. node.id] = node.baseTexture
            end
        end
        savedState.symptomEngineInitialized = true
        ModState.save(savedState)
        if DEBUG_LOG then print("[SymptomEngine][DEBUG] Inicialização salva no ModState.") end
        return
    end

    -- PRIORIDADE 1: Tentar ATIVAR um sintoma que está inativo.
    for _, node in ipairs(SYMPTOM_TREE) do
        local iconKey = "symptomIcon" .. node.id
        if savedState[iconKey] and savedState[iconKey] == node.baseTexture then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[SymptomEngine] ATIVANDO sintoma existente: ID " .. node.id)
                savedState[iconKey] = node.activeTexture
                ModState.save(savedState)
                return
            end
        end
    end

    -- PRIORIDADE 2: Se não ativou ninguém, tentar DESBLOQUEAR um novo sintoma.
    for _, node in ipairs(SYMPTOM_TREE) do
        local iconKey = "symptomIcon" .. node.id
        if not savedState[iconKey] then
            if isDependencyActive(node.dependsOn, savedState) then
                print("[SymptomEngine] DESBLOQUEANDO novo sintoma: ID " .. node.id)
                savedState[iconKey] = node.baseTexture
                ModState.save(savedState)
                return
            end
        end
    end
    
    if DEBUG_LOG then print("[SymptomEngine][DEBUG] Nenhuma evolução de sintoma hoje.") end
end

-- 3. GATILHO: rodar UMA VEZ por dia de jogo (O SEU MÉTODO)
local function onDayTick()
    if not getPlayer() then
        if DEBUG_LOG then print("[SymptomEngine][DEBUG] onDayTick: getPlayer() == nil. Ignorando.") end
        return
    end

    local gt = getGameTime()
    if not gt then
        if DEBUG_LOG then print("[SymptomEngine][DEBUG] onDayTick: getGameTime() == nil. Ignorando.") end
        return
    end

    local ok, day = pcall(function() return gt:getDay() end)
    if not ok or not day then
        if DEBUG_LOG then print("[SymptomEngine][DEBUG] onDayTick: gt:getDay() falhou ou retornou nil. Ignorando.") end
        return
    end
    
    if DEBUG_LOG then
        print(string.format("[SymptomEngine][DAY_TICK] Dia do jogo: %d — executando progressão de sintomas.", day))
    end

    SymptomEngine.updateProgression()
end

-- Registra o EveryDays SOMENTE quando o jogo inicia
Events.OnGameStart.Add(function()
    if DEBUG_LOG then print("[SymptomEngine][DEBUG] OnGameStart: registrando Events.EveryDays.") end
    Events.EveryDays.Add(onDayTick)
end)

return SymptomEngine