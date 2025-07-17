# 🎮 Berr.io

Um jogo de adivinhação de palavras desenvolvido em **Lua** com **Love2D (LÖVE)**.

Berr.io é inspirado em sucessos como Term.ooo, Letreco e Wordle. O jogador deve descobrir a palavra secreta de cinco letras dentro de um número limitado de tentativas, enfrentando níveis variados de dificuldade.

---

## ✅ Funcionalidades

✅ **Interface Completa**
- Menu principal com animações
- Tela de instruções
- Seleção de dificuldade
- Interface responsiva

✅ **Três Modos de Dificuldade**
- **Fácil**: 1 palavra, grade maior
- **Médio**: 2 palavras simultâneas
- **Difícil**: 3 palavras simultâneas

✅ **Mecânicas do Jogo**
- Teclado físico e virtual clicável
- Sistema de cores (verde, amarelo, vermelho)
- Feedback visual das teclas usadas
- Verificação usando dataset de palavras válidas
- Reiniciar jogo (R) ou voltar ao menu (ESC)

---

## 🏗️ Estrutura do Projeto

```
berr.io/
├── main.lua                     # Ponto de entrada e callbacks do LÖVE2D
├── src/
│   ├── libs/
│   │   └── berrio.lua          # Engine do jogo Wordle
│   ├── modules/                 # Módulos do jogo
│   │   ├── config.lua          # Configurações e constantes
│   │   ├── utils.lua           # Funções utilitárias
│   │   ├── ui.lua              # Interface e desenho
│   │   ├── gameLogic.lua       # Lógica do jogo
│   │   └── gameDraw.lua        # Renderização do jogo
│   └── systems/                # Sistemas centrais
│       ├── assetManager.lua    # Gerenciamento de assets
│       └── stateManager.lua    # Gerenciamento de estados
└── assets/                     # Recursos do jogo
    ├── images/
    │   └── fundo.jpg           # Imagem de fundo
    ├── audio/
    │   ├── click_sound.mp3     # Som de clique
    │   ├── invalid_guess_sound.oga # Som de tentativa inválida
    │   ├── win_sound.mp3       # Som de vitória
    │   ├── backspace_sound.mp3 # Som de backspace
    │   └── enter_sound.ogg     # Som de enter
    ├── fonts/
    │   └── PressStart2P-Regular.ttf # Fonte do jogo
    └── data/
        ├── valid_answers.csv   # Palavras-resposta válidas
        └── valid_guesses.csv   # Palavras de tentativa válidas
```

### Arquitetura Modular

O projeto foi estruturado seguindo boas práticas de desenvolvimento em Lua:

- **Separação de responsabilidades**: Cada módulo tem uma função específica
- **Asset management centralizado**: Todos os recursos são gerenciados pelo `assetManager`
- **Estado centralizado**: Transições de tela controladas pelo `stateManager`
- **Código limpo**: main.lua reduzido de 1291 para 280 linhas
- **Organização lógica**: Estrutura de pastas clara e intuitiva

---

## 🛠️ Instalação e Execução

### Pré-requisitos

**No Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install lua5.4 love
```

**No Windows:**
- Baixe o LÖVE2D em: https://love2d.org/
- Instale e adicione ao PATH do sistema

### Executar o Jogo

```bash
# Clone o repositório
git clone https://github.com/pedromchd/berr.io.git
cd berr.io

# Execute o jogo
love .
```

---

## 🎮 Controles

| Ação | Controle |
|------|----------|
| Digitar letras | A-Z |
| Submeter palavra | Enter |
| Apagar letra | Backspace |
| Reiniciar jogo | R (após terminar) |
| Voltar ao menu | ESC |
| Teclado virtual | Mouse/Click |
| Debug | F1 |

---

## 🎯 Como Jogar

1. **Escolha a dificuldade** no menu principal
2. **Digite uma palavra** de 5 letras
3. **Pressione Enter** para submeter
4. **Observe as cores**:
   - 🟩 **Verde**: Letra correta no lugar certo
   - 🟨 **Amarelo**: Letra existe mas no lugar errado
   - 🟥 **Vermelho**: Letra não existe na palavra
5. **Use as dicas** para descobrir a palavra em até 6 tentativas!

### Modos de Dificuldade

- **Fácil**: Uma palavra por vez, grade grande
- **Médio**: Duas palavras simultâneas
- **Difícil**: Três palavras ao mesmo tempo

---

## 📄 Licença

Este projeto foi desenvolvido como trabalho final da disciplina de Linguagens de Programação.

---

**Divirta-se jogando! 🎮✨**
