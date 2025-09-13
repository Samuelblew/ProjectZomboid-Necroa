# NecroaMod - Body Range

Um mod para **Project Zomboid** que amplia a variedade estética e de animações dos zumbis, trazendo mais imersão e realismo à jogabilidade.

## Compatibilidade

Este mod foi desenvolvido para a versão mais recente do **Project Zomboid** e pode ser usado tanto em partidas solo quanto em servidores.

### Estrutura do Projeto

- **Animações**: movimentos adicionais como esbarrões, quedas e tropeços.
- **Roupas**: maior diversidade visual para zumbis masculinos e femininos.
- **Sandbox Options**: arquivo `sandbox-options.txt` para customização.
- **Arquivos XML**: definem roupas e animações de forma expansível.
- **Integração no jogo**: via `mod.info` e demais arquivos padrão.

### Tecnologias / Recursos

- **Project Zomboid Modding API**
- **XMLs de roupas e animações**
- **Configurações Sandbox**
- **Estrutura compatível com Workshop/Mods locais**

## Pré-requisitos

1. Cópia do [Project Zomboid](https://store.steampowered.com/app/108600/Project_Zomboid/) atualizada.
2. Ativar a aba de **Mods** no menu inicial do jogo.
3. (Opcional) Conhecimento básico de XML para expandir roupas/animations.

## Instalação

1. Baixe ou clone este repositório.
2. Copie a pasta do mod para:
   - `C:\Usuários\<SeuNome>\Zomboid\mods` (Windows)
   - `~/Zomboid/mods` (Linux/MacOS)
3. Ative o mod no **menu inicial** do Project Zomboid.

## Executar Localmente (para testes)

### Editar Arquivos
- `media/animations/` → adicionar ou alterar animações.
- `media/clothing/` → personalizar roupas.
- `sandbox-options.txt` → configurar opções personalizadas.

### Estrutura de Arquivos
```bash
NecroaMod/
│── media/
│   ├── animations/
│   ├── clothing/
│   └── sandbox-options.txt
│── mod.info
└── poster.png
