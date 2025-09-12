# Controle de Interação com Ícones via Código

Este sistema permite desabilitar/habilitar a interação com ícones editando diretamente o código.

## Como Usar

### 1. Abra o arquivo de configuração
```
common/media/lua/shared/IconInteractionConfig.lua
```

### 2. Edite a linha principal
```lua
-- true = ícones respondem a cliques (funcionamento normal)
-- false = ícones não respondem a cliques (apenas visuais)
IconInteractionConfig.ENABLE_INTERACTION = true
```

### 3. Salve o arquivo
- **true** = Ícones funcionam normalmente (respondem a cliques)
- **false** = Ícones são apenas visuais (não respondem a cliques)

## Exemplos

### Para DESABILITAR ícones (apenas visuais):
```lua
IconInteractionConfig.ENABLE_INTERACTION = false
```

### Para HABILITAR ícones (funcionamento normal):
```lua
IconInteractionConfig.ENABLE_INTERACTION = true
```

## O que acontece quando desabilitado:

- ✅ Ícones continuam visíveis
- ✅ Ícones continuam sendo renderizados
- ❌ Ícones **NÃO respondem a cliques**
- ❌ **NÃO é possível** alterar configurações

## O que acontece quando habilitado:

- ✅ Ícones respondem a cliques normalmente
- ✅ É possível alterar configurações
- ✅ Toda funcionalidade original funciona

## Vantagens

1. **Controle via Código**: Edite diretamente no arquivo
2. **Não Quebra Código**: Ícones continuam visíveis
3. **Fácil de Usar**: Apenas mude `true` para `false`
4. **Reversível**: Mude de volta para `true` quando quiser

## Resumo

- **DESABILITAR**: Mude para `false` no arquivo de configuração
- **HABILITAR**: Mude para `true` no arquivo de configuração
- **SALVAR**: Salve o arquivo após fazer a mudança

Simples assim! 🎯
