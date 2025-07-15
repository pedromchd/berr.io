# 🎮 Berr.io
Este é um jogo desenvolvido em **Lua**, utilizando o framework **Love2D (LÖVE)**.<br><br>
Berr.io é um jogo de adivinhação de palavras inspirado em sucessos como Term.ooo, Letreco e Wordle. Nele, o jogador deve descobrir a palavra secreta de cinco letras dentro de um número limitado de tentativas, enfrentando níveis variados de dificuldade.

O desafio está em usar as dicas estratégicas para acertar a palavra correta antes que as chances acabem. Simples, viciante e perfeito para quem gosta de exercitar o raciocínio e o vocabulário.

---

## ✅ Funcionalidades Implementadas

✅ **Interface completa** - Menu principal, instruções, seleção de dificuldade
✅ **Três modos de dificuldade:**
- **Fácil**: 1 palavra, grade maior
- **Médio**: 2 palavras simultâneas
- **Difícil**: 3 palavras simultâneas

✅ **Mecânicas do jogo:**
- Digitação no teclado (físico ou virtual)
- Escrita no board com feedback visual
- Verificação de palavras usando dataset em CSV
- Sistema de cores (verde, amarelo, vermelho)
- Indicação visual do estado das teclas

✅ **Interação:**
- Teclado virtual clicável
- Mensagens de feedback
- Reiniciar jogo (tecla R)
- Voltar ao menu (ESC)

✅ **Dataset integrado:**
- `valid_answers.csv` - palavras que podem ser sorteadas
- `valid_guesses.csv` - palavras válidas para tentativas

---

## 🛠️ Instalação

### 1. Instalar o Lua

Abra o terminal e digite:

```bash
sudo apt update
sudo apt install lua5.4
```
Verifique a instalação com:

```bash
lua -v
```
### 2. Instalar o LOVE2D

Abra o terminal e digite:

```bash
sudo apt install love
```
Verifique a instalação com:

```bash
love --version
```

### Executar o jogo:

Abra o terminal e digite:

```bash
love .
```

## 🎮 Controles

- **Letras A-Z**: Digitar
- **Enter**: Submeter palavra
- **Backspace**: Apagar letra
- **R**: Reiniciar jogo (quando terminar)
- **ESC**: Voltar ao menu
- **Mouse**: Clicar no teclado virtual

## 📁 Arquivos Principais

- `main.lua` - Lógica principal do jogo e interface
- `libraries/berrio.lua` - Engine do jogo Wordle
- `assets/` - Recursos (fontes, sons, imagens, datasets)
