-- IconInteractionConfig.lua
-- Configuração para controlar interação com ícones via código

local IconInteractionConfig = {}

-- ========================================
-- CONFIGURAÇÃO PRINCIPAL - EDITE AQUI
-- ========================================

-- true = ícones respondem a cliques (funcionamento normal)
-- false = ícones não respondem a cliques (apenas visuais)
IconInteractionConfig.ENABLE_INTERACTION = true

-- ========================================
-- CONFIGURAÇÕES AVANÇADAS (OPCIONAL)
-- ========================================

-- Mensagem de log quando interação é desabilitada
IconInteractionConfig.DISABLE_MESSAGE = "Interação com ícones DESABILITADA via código"

-- Mensagem de log quando interação é habilitada  
IconInteractionConfig.ENABLE_MESSAGE = "Interação com ícones HABILITADA via código"

-- ========================================
-- FUNÇÕES DO SISTEMA (NÃO EDITE)
-- ========================================

-- Função para verificar se interação está habilitada
function IconInteractionConfig.isInteractionEnabled()
    return IconInteractionConfig.ENABLE_INTERACTION
end

-- Função para obter configuração atual
function IconInteractionConfig.getConfig()
    return {
        enableInteraction = IconInteractionConfig.ENABLE_INTERACTION,
        disableMessage = IconInteractionConfig.DISABLE_MESSAGE,
        enableMessage = IconInteractionConfig.ENABLE_MESSAGE
    }
end

-- Função para log de status
function IconInteractionConfig.logStatus()
    if IconInteractionConfig.ENABLE_INTERACTION then
        print("[IconInteractionConfig] " .. IconInteractionConfig.ENABLE_MESSAGE)
    else
        print("[IconInteractionConfig] " .. IconInteractionConfig.DISABLE_MESSAGE)
    end
end

return IconInteractionConfig
