---

# NecroaMod - Body Range

Um mod para **Project Zomboid** que amplia a variedade estética e de animações dos zumbis, trazendo mais imersão e realismo à jogabilidade.

## Estrutura do Mod

* **Animações personalizadas**: esbarrões, quedas e tropeços para zumbis.
* **Conjuntos de roupas**: maior diversidade visual para zumbis masculinos e femininos.
* **Configurações Sandbox**: arquivo `sandbox-options.txt` com opções customizáveis para o jogador.
* **XMLs organizados**: roupas e animações bem estruturadas, permitindo fácil expansão.
* **Integração no jogo**: via `mod.info` e demais arquivos padrão de mods.

## Tecnologias / Recursos Usados

* **Project Zomboid Modding API**
* **Arquivos XML** para roupas e animações
* **Configurações Sandbox** para customização
* **Estrutura compatível** com Workshop/Mods locais

## Pré-requisitos

* Cópia do **Project Zomboid** atualizada
* Habilitar a aba de Mods no menu inicial
* (Opcional) Conhecimentos básicos em edição de XML para expandir roupas/animations

## Instalação

1. Baixe ou clone este repositório.
2. Copie a pasta do mod para:

   * `C:\Usuários\<SeuNome>\Zomboid\mods` (Windows)
   * `~/Zomboid/mods` (Linux/MacOS)
3. Ative o mod no **menu inicial** do jogo.

## Executar Localmente (para testes/edição)

* Edite os arquivos XML em qualquer editor de texto.
* Ajuste `sandbox-options.txt` para personalizar comportamento.
* Teste no modo Sandbox do Project Zomboid.

## Estrutura de Arquivos

```
NecroaMod/
│── media/
│   ├── animations/
│   ├── clothing/
│   └── sandbox-options.txt
│── mod.info
└── poster.png
```

## Licença

Este mod é distribuído gratuitamente para uso não comercial.

---
