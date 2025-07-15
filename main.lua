-- Menu berr.io com tela de instruções
local menu = {}
local Berrio = require("libraries.berrio")

-- Estados da tela
local gameState = "menu" -- "menu", "instructions", "difficulty", "game"
local bounceTime = 0

-- Instâncias do jogo
local gameInstances = {easy = nil, medium = {}, hard = {}}

-- Estado do jogo atual
local currentInput = ""
local currentRow = 1
local currentCol = 1
local showingMessage = false
local messageText = ""
local messageTime = 0
local messageColor = "text"
local currentGridIndex = 1 -- Controla qual grid está ativo nos modos médio/difícil

-- Estado das teclas do teclado
local keyboardState = {}

-- Debug info
local debugInfo = {}
local showDebug = false

-- Configurações da tela
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

-- Imagem de fundo
local backgroundImage

-- Fontes responsivas
local titleFontSize = 60
local difficultyTitleFontSize = 40
local buttonFontSize = 30
local textFontSize = 18

local titleFont, difficultyTitleFont, buttonFont, textFont

-- Cores
local colors = {
    background = {0.08, 0.08, 0.08},
    title = {1, 1, 1},
    button = {0.15, 0.15, 0.15},
    buttonHover = {0.25, 0.25, 0.25},
    buttonText = {1, 1, 1},
    border = {0.35, 0.35, 0.35},
    green = {0.4, 0.8, 0.4},
    yellow = {0.9, 0.8, 0.2},
    red = {0.8, 0.3, 0.3},
    text = {0.9, 0.9, 0.9}
}

-- Teclado virtual
local keyboardLayout = {
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L"},
    {"←", "Z", "X", "C", "V", "B", "N", "M", "ENTER"}
}

-- Botões do menu principal (centralizados automaticamente)
local menuButtons = {
    {
        text = "Jogar",
        relativeY = 0.475, -- porcentagem da altura da tela
        action = function() gameState = "difficulty" end
    }, {
        text = "Como Jogar",
        relativeY = 0.625, -- porcentagem da altura da tela
        action = function() gameState = "instructions" end
    }
}

-- Botões da tela de dificuldade (centralizados automaticamente)
local difficultyButtons = {
    {
        text = "Fácil",
        relativeY = 0.3125,
        action = function()
            gameState = "game"
            initGame("easy")
        end
    }, {
        text = "Médio",
        relativeY = 0.5,
        action = function()
            gameState = "game_medium"
            initGame("medium")
        end
    }, {
        text = "Difícil",
        relativeY = 0.6875,
        action = function()
            gameState = "game_hard"
            initGame("hard")
        end
    }
}

local backStates = {
    instructions = true,
    difficulty = true,
    game = true,
    game_medium = true,
    game_hard = true
}

-- Estado das teclas do teclado
local keyboardState = {}

-- Função para atualizar dimensões da tela
function updateScreenDimensions()
    screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
end

-- Funções de escala responsiva
function getScaleX()
    return screenWidth / 1100 -- baseado na largura original
end

function getScaleY()
    return screenHeight / 800 -- baseado na altura original
end

function getScale()
    return math.min(getScaleX(), getScaleY()) -- mantém proporção
end

-- Função para calcular dimensões da grade responsivamente
function getGridDimensions()
    local scale = getScale()
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

-- Função para dimensões da grade no modo fácil (maior)
function getGridDimensionsEasy()
    local scale = getScale()
    return {boxSize = math.floor(70 * scale), spacing = math.floor(12 * scale)}
end

-- Função para dimensões da grade no modo médio (maior)
function getGridDimensionsMedium()
    local scale = getScale()
    return {boxSize = math.floor(70 * scale), spacing = math.floor(11 * scale)}
end

-- Função para dimensões da grade no modo difícil (tamanho original)
function getGridDimensionsHard()
    local scale = getScale()
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

-- Função para calcular área de conteúdo centralizada
function getContentArea()
    local maxContentWidth = 1100
    local maxContentHeight = 800
    local scale = getScale()

    local contentWidth = math.min(screenWidth, maxContentWidth * scale)
    local contentHeight = math.min(screenHeight, maxContentHeight * scale)

    local offsetX = (screenWidth - contentWidth) / 2
    local offsetY = (screenHeight - contentHeight) / 2

    return {x = offsetX, y = offsetY, width = contentWidth, height = contentHeight, scale = scale}
end

-- Função para recarregar fontes com escala
function loadFonts()
    local scale = getScale()
    titleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf",
                                      math.floor(titleFontSize * scale))
    difficultyTitleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf",
                                                math.floor(difficultyTitleFontSize * scale))
    buttonFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf",
                                       math.floor(buttonFontSize * scale))
    textFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf",
                                     math.floor(textFontSize * scale))
end

-- Função para calcular dimensões dos botões responsivamente
function getButtonDimensions()
    local scale = getScale()
    return {width = math.floor(350 * scale), height = math.floor(100 * scale)}
end

function love.resize(w, h)
    updateScreenDimensions()
    loadFonts()
    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

-- Função para centralizar botões responsivamente
function centerButtons(buttons)
    local buttonDim = getButtonDimensions()
    local content = getContentArea()

    for _, button in ipairs(buttons) do
        -- Store the original percentage if not already present
        if not button.relativeY and button.y then button.relativeY = button.y end
        button.x = content.x + (content.width - buttonDim.width) / 2
        button.width = buttonDim.width
        button.height = buttonDim.height
        button.y = content.y + math.floor((button.relativeY or 0) * content.height)
    end
end

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    updateScreenDimensions()
    love.window.setTitle("berr.io")
    backgroundImage = love.graphics.newImage("assets/fundo.jpg")
    clickSound = love.audio.newSource("assets/click_sound.mp3", "static")

    -- Carregar fontes com escala
    loadFonts()

    -- Centralizar todos os botões
    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

-- Função para inicializar o jogo
function initGame(difficulty)
    if difficulty == "easy" then
        gameInstances.easy = Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv")
    elseif difficulty == "medium" then
        gameInstances.medium = {
            Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv"),
            Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv")
        }
    elseif difficulty == "hard" then
        gameInstances.hard = {
            Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv"),
            Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv"),
            Berrio:new("assets/valid_answers.csv", "assets/valid_guesses.csv")
        }
    end

    -- Reset input state
    currentInput = ""
    currentRow = 1
    currentCol = 1
    showingMessage = false
    messageText = ""
    messageTime = 0
    currentGridIndex = 1 -- Reset grid index

    -- Reset keyboard state
    keyboardState = {}
end

-- Função para obter a instância do jogo atual
function getCurrentGameInstance(gridIndex)
    gridIndex = gridIndex or currentGridIndex
    if gameState == "game" then
        return gameInstances.easy
    elseif gameState == "game_medium" then
        return gameInstances.medium[gridIndex]
    elseif gameState == "game_hard" then
        return gameInstances.hard[gridIndex]
    end
    return nil
end

-- Função para processar entrada de tecla
function processKeyInput(key)
    if showingMessage then return end

    local currentGame = getCurrentGameInstance(currentGridIndex)
    if not currentGame or currentGame.gameOver then return end

    if key == "backspace" or key == "←" then
        if #currentInput > 0 then
            currentInput = currentInput:sub(1, -2)
            currentCol = math.max(1, currentCol - 1)
        end
    elseif key == "return" or key == "enter" or key == "ENTER" then
        if #currentInput == 5 then
            local result = currentGame:makeGuess(currentInput)

            -- Capturar informações de debug
            debugInfo = {
                word = currentInput,
                gridIndex = currentGridIndex,
                gameState = gameState,
                answer = currentGame.currentAnswer,
                won = result.won,
                gameOver = result.gameOver,
                perfectMatch = result.match and result.match.perfect or false,
                matchDetails = result.match and result.match.letters or {},
                resultSuccess = result.success
            }

            if result.success then
                currentRow = currentRow + 1
                currentInput = ""
                currentCol = 1

                -- Atualizar estado do teclado
                updateKeyboardState()

                if result.gameOver then
                    if result.won then
                        showMessage("Parabéns! Você acertou!", "green", 3)

                        -- Verificar se deve avançar para próximo grid (modo médio/difícil)
                        if gameState == "game_medium" and currentGridIndex < 2 then
                            currentGridIndex = currentGridIndex + 1
                            currentRow = 1
                            currentCol = 1
                            keyboardState = {} -- Limpar estado do teclado
                            showMessage("Próximo grid! Continue jogando!", "green", 2)
                        elseif gameState == "game_hard" and currentGridIndex < 3 then
                            currentGridIndex = currentGridIndex + 1
                            currentRow = 1
                            currentCol = 1
                            keyboardState = {} -- Limpar estado do teclado
                            showMessage("Próximo grid! Continue jogando!", "green", 2)
                        end
                    else
                        showMessage("Fim de jogo! A palavra era: " ..
                                        currentGame.currentAnswer:upper(), "red", 5)
                    end
                end
            else
                showMessage(result.message, "red", 2)
            end
        else
            showMessage("Digite uma palavra de 5 letras", "yellow", 2)
        end
    elseif key:match("^%a$") and #currentInput < 5 then
        currentInput = currentInput .. key:upper()
        currentCol = currentCol + 1
    end
end

-- Função para mostrar mensagem temporária
function showMessage(text, color, duration)
    messageText = text
    messageColor = color
    messageTime = duration
    showingMessage = true
end

-- Função para atualizar estado do teclado
function updateKeyboardState()
    -- Resetar estado
    keyboardState = {}

    local currentGame = getCurrentGameInstance(currentGridIndex)
    if not currentGame then return end

    local gameState = currentGame:getGameState()

    for _, attempt in ipairs(gameState.attempts) do
        for i = 1, #attempt.word do
            local letter = attempt.word:sub(i, i):upper()
            local result = attempt.result.letters[i]

            if result == true then
                keyboardState[letter] = "correct"
            elseif result == false and keyboardState[letter] ~= "correct" then
                keyboardState[letter] = "wrong_position"
            elseif result == nil and keyboardState[letter] ~= "correct" and keyboardState[letter] ~=
                "wrong_position" then
                keyboardState[letter] = "not_in_word"
            end
        end
    end
end

function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    bounceTime = bounceTime + dt

    -- Atualizar timer de mensagem
    if showingMessage then
        messageTime = messageTime - dt
        if messageTime <= 0 then showingMessage = false end
    end

    if gameState == "menu" then
        for _, button in ipairs(menuButtons) do
            button.isHovered = isPointInRect(mouseX, mouseY, button.x, button.y, button.width,
                                             button.height)
        end
    elseif gameState == "difficulty" then
        for _, button in ipairs(difficultyButtons) do
            button.isHovered = isPointInRect(mouseX, mouseY, button.x, button.y, button.width,
                                             button.height)
        end
    end
end

function love.draw()
    -- Desenhar fundo em toda a tela
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundImage, 0, 0, 0, screenWidth / backgroundImage:getWidth(),
                       screenHeight / backgroundImage:getHeight())

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    -- Aplicar transformação para área de conteúdo centralizada
    local content = getContentArea()
    love.graphics.push()
    love.graphics.translate(content.x, content.y)

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "instructions" then
        drawInstructions()
    elseif gameState == "difficulty" then
        drawDifficulty()
    elseif gameState == "game" then
        drawGameEasy()
    elseif gameState == "game_medium" then
        drawGameMid()
    elseif gameState == "game_hard" then
        drawGameHard()
    end

    love.graphics.pop()

    -- Desenhar informações de debug
    drawDebugInfo()
end

function drawMenu()
    local content = getContentArea()

    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    local text = "Trabalho final da disciplina de LP, feito em LOVE2D. ®"
    local textWidth = textFont:getWidth(text)
    love.graphics.print(text, (content.width - textWidth) / 2, content.height * 0.9500)

    love.graphics.setFont(titleFont)
    local titleText = "berr.io"
    local titleWidth = titleFont:getWidth(titleText)
    local titleHeight = titleFont:getHeight()
    local scale = 1 + 0.05 * math.sin(bounceTime * 3)
    local angle = math.rad(2) * math.sin(bounceTime * 2)
    local centerX = content.width / 2
    local centerY = content.height * 0.225 + titleHeight / 2

    love.graphics.setColor(colors.title)
    love.graphics.push()
    love.graphics.translate(centerX, centerY)
    love.graphics.rotate(angle)
    love.graphics.scale(scale, scale)
    love.graphics.translate(-titleWidth / 2, -titleHeight / 2)
    love.graphics.print(titleText, 0, 0)
    love.graphics.pop()

    love.graphics.setFont(buttonFont)
    for _, button in ipairs(menuButtons) do
        local buttonX = button.x - content.x
        local buttonY = button.y - content.y

        love.graphics.setColor(button.isHovered and colors.buttonHover or colors.button)
        love.graphics.rectangle("fill", buttonX, buttonY, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", buttonX, buttonY, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = buttonX + (button.width - textWidth) / 2
        local textY = buttonY + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

-- Função para quebrar texto conforme largura disponível
function wrapText(text, font, maxWidth)
    local words = {}
    for word in text:gmatch("%S+") do table.insert(words, word) end

    local lines = {}
    local currentLine = ""

    for _, word in ipairs(words) do
        local testLine = currentLine == "" and word or (currentLine .. " " .. word)
        if font:getWidth(testLine) <= maxWidth then
            currentLine = testLine
        else
            if currentLine ~= "" then
                table.insert(lines, currentLine)
                currentLine = word
            else
                table.insert(lines, word)
            end
        end
    end

    if currentLine ~= "" then table.insert(lines, currentLine) end

    return lines
end

function drawInstructions()
    local content = getContentArea()
    local padding = content.width * 0.05 -- 5% de padding

    love.graphics.setColor(colors.title)
    love.graphics.setFont(titleFont)
    local titleText = "Como Jogar"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.08)

    love.graphics.setFont(textFont)
    local instructions = {
        {
            text = "• Você terá 6 tentativas. Cada uma delas deve ser uma palavra que exista.",
            color = "text"
        }, {text = "• Acentos e cedilha são ignorados.", color = "text"}, {
            text = "• Após chutar, as letras mudarão para indicar o quão perto você está da resposta:",
            color = "text"
        }, {
            text = "- Se a letra for VERDE, ela está presente na palavra e na posição correta.",
            color = "green"
        }, {
            text = "- Se a letra for AMARELA, ela está presente na palavra, mas na posição errada.",
            color = "yellow"
        }, {text = "- Se a letra for VERMELHA, ela NÃO está na palavra.", color = "red"}
    }

    local lineHeight = textFont:getHeight() * 1.4
    local startY = content.height * 0.22
    local maxTextWidth = content.width - padding * 2
    local currentY = startY

    for i, instruction in ipairs(instructions) do
        local wrappedLines = wrapText(instruction.text, textFont, maxTextWidth)

        -- Determinar cor baseada no tipo de instrução
        local color = colors[instruction.color] or colors.text

        for _, wrappedLine in ipairs(wrappedLines) do
            love.graphics.setColor(color)
            love.graphics.print(wrappedLine, padding, currentY)
            currentY = currentY + lineHeight
        end

        -- Adicionar espaço extra após certas instruções
        if i == 1 or i == 2 or i == 3 then currentY = currentY + lineHeight * 1.5 end
    end

    -- Seção de exemplos mais abaixo
    local examplesY = content.height * 0.72
    love.graphics.setColor(colors.text)
    local examplesTitle = "Exemplos:"
    local examplesTitleWidth = textFont:getWidth(examplesTitle)
    love.graphics.print(examplesTitle, (content.width - examplesTitleWidth) / 2, examplesY)

    local squareSize = 20 * getScale()
    local exampleStartY = examplesY + lineHeight * 1.5
    local exampleCenterX = content.width / 2

    -- Exemplo Verde
    love.graphics.setColor(colors.green)
    love.graphics.rectangle("fill", exampleCenterX - 150 * getScale(), exampleStartY, squareSize,
                            squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição correta", exampleCenterX - 120 * getScale(), exampleStartY + 2)

    -- Exemplo Amarelo
    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", exampleCenterX - 150 * getScale(),
                            exampleStartY + squareSize * 1.8, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição errada", exampleCenterX - 120 * getScale(),
                        exampleStartY + squareSize * 1.8 + 2)

    -- Exemplo Vermelho
    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", exampleCenterX - 150 * getScale(),
                            exampleStartY + squareSize * 3.6, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Não está na palavra", exampleCenterX - 120 * getScale(),
                        exampleStartY + squareSize * 3.6 + 2)

    -- Instrução para voltar
    love.graphics.setColor(colors.text)
    local backText = "Pressione ESC para voltar"
    local backTextWidth = textFont:getWidth(backText)
    love.graphics.print(backText, (content.width - backTextWidth) / 2, content.height * 0.94)
end

function drawDifficulty()
    local content = getContentArea()

    love.graphics.setColor(colors.title)
    love.graphics.setFont(difficultyTitleFont)
    local titleText = "Escolha a Dificuldade"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.125)

    love.graphics.setFont(buttonFont)
    for _, button in ipairs(difficultyButtons) do
        local buttonX = button.x - content.x
        local buttonY = button.y - content.y

        love.graphics.setColor(button.isHovered and colors.buttonHover or colors.button)
        love.graphics.rectangle("fill", buttonX, buttonY, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", buttonX, buttonY, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = buttonX + (button.width - textWidth) / 2
        local textY = buttonY + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

-- Função auxiliar para desenhar uma grade em uma posição específica com linhas e colunas definidas
function drawGridAt(startX, startY, rows, cols, gridDimensions, gameInstance)
    local grid = gridDimensions or getGridDimensions()
    local gameState = gameInstance and gameInstance:getGameState() or nil

    for row = 0, rows - 1 do
        for col = 0, cols - 1 do
            local x = startX + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)

            -- Determinar cor da caixa
            local boxColor = {0.2, 0.2, 0.2}
            local textColor = colors.buttonText
            local letter = ""

            if gameState then
                local attemptIndex = row + 1
                local letterIndex = col + 1

                if attemptIndex <= #gameState.attempts then
                    -- Tentativa já feita
                    local attempt = gameState.attempts[attemptIndex]
                    letter = attempt.word:sub(letterIndex, letterIndex):upper()

                    local letterResult = attempt.result.letters[letterIndex]
                    if letterResult == true then
                        boxColor = colors.green
                    elseif letterResult == false then
                        boxColor = colors.yellow
                    else
                        boxColor = colors.red
                    end
                elseif attemptIndex == currentRow and gameInstance ==
                    getCurrentGameInstance(currentGridIndex) then
                    -- Linha atual sendo digitada (apenas no grid ativo)
                    if letterIndex <= #currentInput then
                        letter = currentInput:sub(letterIndex, letterIndex)
                        boxColor = {0.3, 0.3, 0.3}
                    end
                end
            end

            love.graphics.setColor(boxColor)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())

            -- Desenhar letra
            if letter ~= "" then
                love.graphics.setFont(buttonFont)
                love.graphics.setColor(textColor)
                local letterWidth = buttonFont:getWidth(letter)
                local letterHeight = buttonFont:getHeight()
                local letterX = x + (grid.boxSize - letterWidth) / 2
                local letterY = y + (grid.boxSize - letterHeight) / 2
                love.graphics.print(letter, letterX, letterY)
            end
        end
    end
end

-- Função para desenhar mensagem
function drawMessage()
    if not showingMessage then
        -- Mostrar instrução de reiniciar se o jogo acabou
        local currentGame = getCurrentGameInstance()
        if currentGame and currentGame.gameOver then
            local content = getContentArea()
            love.graphics.setFont(textFont)
            love.graphics.setColor(colors.text)

            local restartText = "Pressione R para jogar novamente ou ESC para voltar ao menu"
            local textWidth = textFont:getWidth(restartText)
            local x = (content.width - textWidth) / 2
            local y = content.height * 0.90

            love.graphics.print(restartText, x, y)
        end
        return
    end

    local content = getContentArea()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors[messageColor] or colors.text)

    local textWidth = buttonFont:getWidth(messageText)
    local textHeight = buttonFont:getHeight()
    local x = (content.width - textWidth) / 2
    local y = content.height * 0.85

    -- Fundo da mensagem
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x - 20, y - 10, textWidth + 40, textHeight + 20, 10)

    -- Texto da mensagem
    love.graphics.setColor(colors[messageColor] or colors.text)
    love.graphics.print(messageText, x, y)
end

function drawGameEasy()
    local content = getContentArea()

    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Grade 6x5 (centralizada) - tamanho maior
    local grid = getGridDimensionsEasy()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local startX = (content.width - gridWidth) / 2
    local startY = content.height * 0.12

    drawGridAt(startX, startY - 15, 6, 5, grid, gameInstances.easy)

    -- Teclado virtual
    drawVirtualKeyboard()

    -- Mensagem
    drawMessage()
end

function drawGameMid()
    local content = getContentArea()

    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Duas grades 6x5 lado a lado - tamanho médio
    local grid = getGridDimensionsMedium()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridSeparation = math.floor(40 * getScale())
    local totalWidth = gridWidth * 2 + gridSeparation
    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + gridSeparation
    local startY = content.height * 0.12

    drawGridAt(startX1, startY - 15, 6, 5, grid, gameInstances.medium[1])
    drawGridAt(startX2, startY - 15, 6, 5, grid, gameInstances.medium[2])

    -- Indicador visual do grid ativo
    if currentGridIndex == 1 then
        love.graphics.setColor(colors.green)
        love.graphics.setLineWidth(3 * getScale())
        love.graphics.rectangle("line", startX1 - 5, startY - 20, gridWidth + 10,
                                6 * grid.boxSize + 5 * grid.spacing + 10)
    elseif currentGridIndex == 2 then
        love.graphics.setColor(colors.green)
        love.graphics.setLineWidth(3 * getScale())
        love.graphics.rectangle("line", startX2 - 5, startY - 20, gridWidth + 10,
                                6 * grid.boxSize + 5 * grid.spacing + 10)
    end
    love.graphics.setLineWidth(1)

    -- Teclado virtual abaixo das grades
    drawVirtualKeyboard()

    -- Mensagem
    drawMessage()
end

function drawGameHard()
    local content = getContentArea()

    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Três grades 6x5 lado a lado - tamanho original (menor)
    local grid = getGridDimensionsHard()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local spacingBetweenGrids = math.floor(30 * getScale())
    local totalWidth = gridWidth * 3 + spacingBetweenGrids * 2

    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + spacingBetweenGrids
    local startX3 = startX2 + gridWidth + spacingBetweenGrids

    local startY = content.height * 0.12

    drawGridAt(startX1, startY - 15, 6, 5, grid, gameInstances.hard[1])
    drawGridAt(startX2, startY - 15, 6, 5, grid, gameInstances.hard[2])
    drawGridAt(startX3, startY - 15, 6, 5, grid, gameInstances.hard[3])

    -- Indicador visual do grid ativo
    local activeX = startX1
    if currentGridIndex == 2 then
        activeX = startX2
    elseif currentGridIndex == 3 then
        activeX = startX3
    end

    love.graphics.setColor(colors.green)
    love.graphics.setLineWidth(3 * getScale())
    love.graphics.rectangle("line", activeX - 5, startY - 20, gridWidth + 10,
                            6 * grid.boxSize + 5 * grid.spacing + 10)
    love.graphics.setLineWidth(1)

    -- Teclado virtual maior para o modo difícil
    drawVirtualKeyboardHard()

    -- Mensagem
    drawMessage()
end

function drawVirtualKeyboard()
    local content = getContentArea()
    local scale = getScale()
    local keyHeight = math.floor(70 * scale)
    local keyWidth = math.floor(60 * scale)
    local enterWidth = math.floor(150 * scale)
    local spacing = math.floor(12 * scale)
    local enterExtraMargin = math.floor(30 * scale)
    local startY = content.height * 0.70 -- posicionamento responsivo

    for rowIndex, row in ipairs(keyboardLayout) do
        local totalWidth = 0
        for _, key in ipairs(row) do
            if key == "ENTER" then
                totalWidth = totalWidth + enterWidth + enterExtraMargin
            else
                totalWidth = totalWidth + keyWidth
            end
            totalWidth = totalWidth + spacing
        end
        totalWidth = totalWidth - spacing

        local startX = (content.width - totalWidth) / 2
        local x = startX

        for _, key in ipairs(row) do
            local thisKeyWidth = (key == "ENTER") and enterWidth or keyWidth
            local margin = (key == "ENTER") and enterExtraMargin or 0

            x = x + margin
            local y = startY + (rowIndex - 1) * (keyHeight + spacing)

            -- Determinar cor baseada no estado da tecla
            local keyColor = {0.15, 0.15, 0.15}
            if key ~= "←" and key ~= "ENTER" then
                local keyState = keyboardState[key]
                if keyState == "correct" then
                    keyColor = colors.green
                elseif keyState == "wrong_position" then
                    keyColor = colors.yellow
                elseif keyState == "not_in_word" then
                    keyColor = colors.red
                end
            end

            love.graphics.setColor(keyColor)
            love.graphics.rectangle("fill", x, y, thisKeyWidth, keyHeight, 6 * scale, 6 * scale)

            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, thisKeyWidth, keyHeight, 6 * scale, 6 * scale)

            love.graphics.setColor(colors.buttonText)
            local text = (key == "←") and "<" or key
            local textWidth = buttonFont:getWidth(text)
            local textHeight = buttonFont:getHeight()
            love.graphics.print(text, x + (thisKeyWidth - textWidth) / 2,
                                y + (keyHeight - textHeight) / 2)

            x = x + thisKeyWidth + spacing
        end
    end
end

function drawVirtualKeyboardHard()
    local content = getContentArea()
    local scale = getScale()
    local keyHeight = math.floor(85 * scale) -- Maior
    local keyWidth = math.floor(75 * scale) -- Maior
    local enterWidth = math.floor(180 * scale) -- Maior
    local spacing = math.floor(15 * scale) -- Maior
    local enterExtraMargin = math.floor(30 * scale)
    local startY = content.height * 0.63 -- posicionamento responsivo

    for rowIndex, row in ipairs(keyboardLayout) do
        local totalWidth = 0
        for _, key in ipairs(row) do
            if key == "ENTER" then
                totalWidth = totalWidth + enterWidth + enterExtraMargin
            else
                totalWidth = totalWidth + keyWidth
            end
            totalWidth = totalWidth + spacing
        end
        totalWidth = totalWidth - spacing

        local startX = (content.width - totalWidth) / 2
        local x = startX

        for _, key in ipairs(row) do
            local thisKeyWidth = (key == "ENTER") and enterWidth or keyWidth
            local margin = (key == "ENTER") and enterExtraMargin or 0

            x = x + margin
            local y = startY + (rowIndex - 1) * (keyHeight + spacing)

            -- Determinar cor baseada no estado da tecla
            local keyColor = {0.15, 0.15, 0.15}
            if key ~= "←" and key ~= "ENTER" then
                local keyState = keyboardState[key]
                if keyState == "correct" then
                    keyColor = colors.green
                elseif keyState == "wrong_position" then
                    keyColor = colors.yellow
                elseif keyState == "not_in_word" then
                    keyColor = colors.red
                end
            end

            love.graphics.setColor(keyColor)
            love.graphics.rectangle("fill", x, y, thisKeyWidth, keyHeight, 6 * scale, 6 * scale)

            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, thisKeyWidth, keyHeight, 6 * scale, 6 * scale)

            love.graphics.setColor(colors.buttonText)
            local text = (key == "←") and "<" or key
            local textWidth = buttonFont:getWidth(text)
            local textHeight = buttonFont:getHeight()
            love.graphics.print(text, x + (thisKeyWidth - textWidth) / 2,
                                y + (keyHeight - textHeight) / 2)

            x = x + thisKeyWidth + spacing
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" then
            for _, btn in ipairs(menuButtons) do
                if isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif gameState == "difficulty" then
            for _, btn in ipairs(difficultyButtons) do
                if isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif gameState == "game" or gameState == "game_medium" or gameState == "game_hard" then
            -- Verificar cliques no teclado virtual
            local keyPressed = getVirtualKeyPressed(x, y)
            if keyPressed then
                love.audio.play(clickSound)
                processKeyInput(keyPressed)
            end
        end
    end
end

-- Função para detectar clique no teclado virtual
function getVirtualKeyPressed(mouseX, mouseY)
    local content = getContentArea()
    local scale = getScale()
    local keyHeight, keyWidth, enterWidth, spacing, startY

    if gameState == "game_hard" then
        keyHeight = math.floor(85 * scale)
        keyWidth = math.floor(75 * scale)
        enterWidth = math.floor(180 * scale)
        spacing = math.floor(15 * scale)
        startY = content.y + content.height * 0.63
    else
        keyHeight = math.floor(70 * scale)
        keyWidth = math.floor(60 * scale)
        enterWidth = math.floor(150 * scale)
        spacing = math.floor(12 * scale)
        startY = content.y + content.height * 0.70
    end

    local enterExtraMargin = math.floor(30 * scale)

    for rowIndex, row in ipairs(keyboardLayout) do
        local totalWidth = 0
        for _, key in ipairs(row) do
            if key == "ENTER" then
                totalWidth = totalWidth + enterWidth + enterExtraMargin
            else
                totalWidth = totalWidth + keyWidth
            end
            totalWidth = totalWidth + spacing
        end
        totalWidth = totalWidth - spacing

        local startX = content.x + (content.width - totalWidth) / 2
        local x = startX

        for _, key in ipairs(row) do
            local thisKeyWidth = (key == "ENTER") and enterWidth or keyWidth
            local margin = (key == "ENTER") and enterExtraMargin or 0

            x = x + margin
            local y = startY + (rowIndex - 1) * (keyHeight + spacing)

            if isPointInRect(mouseX, mouseY, x, y, thisKeyWidth, keyHeight) then
                if key == "←" then
                    return "backspace"
                elseif key == "ENTER" then
                    return "return"
                else
                    return key:lower()
                end
            end

            x = x + thisKeyWidth + spacing
        end
    end

    return nil
end

function love.keypressed(key)
    if key == "escape" then
        if backStates[gameState] then
            gameState = "menu"
        else
            love.event.quit()
        end
    elseif key == "f1" then
        -- Toggle debug mode
        showDebug = not showDebug
    elseif gameState == "game" or gameState == "game_medium" or gameState == "game_hard" then
        if key == "r" and (getCurrentGameInstance() and getCurrentGameInstance().gameOver) then
            -- Reiniciar o jogo
            if gameState == "game" then
                initGame("easy")
            elseif gameState == "game_medium" then
                initGame("medium")
            elseif gameState == "game_hard" then
                initGame("hard")
            end
        else
            processKeyInput(key)
        end
    end
end

-- Função para desenhar informações de debug
function drawDebugInfo()
    if not showDebug or not debugInfo.word then return end

    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 0) -- Amarelo

    local y = 10
    local lineHeight = textFont:getHeight() + 2

    love.graphics.print("=== DEBUG INFO (Press F1 to toggle) ===", 10, y)
    y = y + lineHeight * 2

    love.graphics.print("Palavra digitada: " .. debugInfo.word, 10, y)
    y = y + lineHeight

    love.graphics.print("Palavra resposta: " .. (debugInfo.answer or "N/A"), 10, y)
    y = y + lineHeight

    love.graphics.print("Grid Index: " .. debugInfo.gridIndex, 10, y)
    y = y + lineHeight

    love.graphics.print("Game State: " .. debugInfo.gameState, 10, y)
    y = y + lineHeight

    love.graphics.print("Won: " .. tostring(debugInfo.won), 10, y)
    y = y + lineHeight

    love.graphics.print("Game Over: " .. tostring(debugInfo.gameOver), 10, y)
    y = y + lineHeight

    love.graphics.print("Perfect Match: " .. tostring(debugInfo.perfectMatch), 10, y)
    y = y + lineHeight

    love.graphics.print("Result Success: " .. tostring(debugInfo.resultSuccess), 10, y)
    y = y + lineHeight

    if debugInfo.matchDetails then
        love.graphics.print("Match Details:", 10, y)
        y = y + lineHeight

        -- Garantir que mostramos todos os 5 resultados
        for i = 1, 5 do
            local letter = debugInfo.word:sub(i, i)
            local letterResult = debugInfo.matchDetails[i]
            local resultText = "nil"
            if letterResult == true then
                resultText = "TRUE"
            elseif letterResult == false then
                resultText = "FALSE"
            end
            love.graphics.print("  " .. i .. ": " .. letter .. " -> " .. resultText, 10, y)
            y = y + lineHeight
        end
    end
end

function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end
