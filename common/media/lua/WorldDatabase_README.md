# Sistema de Banco de Dados por Mundo

Este sistema permite armazenar informações específicas de cada mundo, salvando apenas ícones que não sejam o padrão "locker.png".

## Como Funciona

1. **Reset Automático**: O `externalagent.lua` reseta todos os ícones para o padrão
2. **Inicialização do Banco**: Após o reset, o banco de dados é inicializado
3. **Carregamento**: Ícones salvos para o mundo atual são carregados automaticamente
4. **Auto-Save**: Sistema salva automaticamente ícones não-padrão a cada 5 segundos
5. **Isolamento por Mundo**: Cada mundo tem seu próprio banco de dados

## Arquivos do Sistema

### Core
- `WorldDatabase.lua` - Sistema principal do banco de dados
- `externalagent.lua` - Reset automático e inicialização do banco

### Auto-Save
- `WorldDatabaseAutoSave.lua` - Sistema de auto-save automático

### Exemplos
- `WorldDatabaseExample.lua` - Exemplos de uso do sistema

## Funcionalidades

### Salvamento Automático
- Salva ícones não-padrão automaticamente a cada 5 segundos
- Só funciona após o banco ser inicializado
- Remove ícones padrão do banco automaticamente

### Carregamento Automático
- Carrega ícones salvos quando o mundo é iniciado
- Funciona após o reset do externalagent.lua
- Restaura configurações específicas do mundo

### Gerenciamento por Mundo
- Cada mundo tem seu próprio banco de dados
- ID único baseado no nome do mundo e seed
- Dados isolados entre diferentes mundos

## Como Usar

### Uso Automático
O sistema funciona automaticamente:
1. Jogue normalmente
2. Configure seus ícones nos menus
3. Os ícones são salvos automaticamente
4. Ao mudar de mundo, os ícones são resetados
5. Ao voltar ao mundo anterior, os ícones são restaurados

### Uso Manual
```lua
local WorldDatabaseExample = require("WorldDatabaseExample")

-- Salvar ícones manualmente
WorldDatabaseExample.saveCurrentIcons()

-- Carregar ícones salvos
WorldDatabaseExample.loadSavedIcons()

-- Ver estatísticas do mundo atual
WorldDatabaseExample.showCurrentWorldStats()

-- Listar todos os mundos com dados salvos
WorldDatabaseExample.listAllSavedWorlds()

-- Forçar auto-save
WorldDatabaseExample.forceAutoSave()

-- Alterar intervalo de auto-save (em segundos)
WorldDatabaseExample.setAutoSaveInterval(10)
```

## Estrutura dos Dados

### Banco de Dados
```lua
{
    ["Mundo1_Seed1"] = {
        abilities = { [1] = "media/textures/HI.png", ... },
        infections = { [1] = "media/textures/Bird_Icon.png", ... },
        symptoms = { [1] = "media/textures/Cytopathic_Reanimation_Icon.png", ... },
        lastUpdated = timestamp
    },
    ["Mundo2_Seed2"] = { ... }
}
```

### ModState
```lua
{
    abilityIcon1 = "media/textures/HI.png",
    abilityIcon2 = "media/textures/locker.png", -- Não é salvo no banco
    infectionIcon1 = "media/textures/Bird_Icon.png",
    symptomIcon1 = "media/textures/Cytopathic_Reanimation_Icon.png",
    ...
}
```

## Logs do Sistema

O sistema gera logs informativos:
- `[WorldDatabase]` - Operações do banco de dados
- `[WorldDatabaseAutoSave]` - Operações de auto-save
- `[WorldDatabaseExample]` - Exemplos e testes

## Limitações

1. **Dependência do Reset**: Só funciona após o externalagent.lua
2. **Ícones Padrão**: Não salva ícones "locker.png"
3. **Por Mundo**: Dados são específicos de cada mundo
4. **Auto-Save**: Salva apenas quando o menu está aberto

## Troubleshooting

### Banco não inicializado
```
[WorldDatabase] ERRO: Banco não foi inicializado ainda!
```
**Solução**: Aguarde o externalagent.lua executar o reset

### Nenhum ícone salvo
```
[WorldDatabase] Nenhum ícone salvo encontrado para este mundo.
```
**Solução**: Configure alguns ícones nos menus primeiro

### Auto-save não funciona
```
[WorldDatabaseAutoSave] ERRO: Banco não foi inicializado ainda!
```
**Solução**: Verifique se o externalagent.lua está funcionando

## Integração com Menus

O sistema se integra automaticamente com:
- `AbilitiesMenu.lua` - 28 ícones de habilidades
- `InfectionMenu.lua` - 20 ícones de infecção  
- `SymptomMenu.lua` - 31 ícones de sintomas
- `DraggableIcon_Menu.lua` - Menu principal

Todos os menus são atualizados automaticamente quando os dados são carregados do banco.
