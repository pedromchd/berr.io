-- Menu berr.io com tela de instruções
local menu = {}

-- Estados da tela
local gameState = "menu" -- "menu", "instructions", "difficulty", "game"
local bounceTime = 0

-- Configurações da tela
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

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

-- Imagem de fundo
local backgroundImage

-- Fontes responsivas
local titleFontSize = 60
local difficultyTitleFontSize = 40
local buttonFontSize = 25
local textFontSize = 15

local titleFont, difficultyTitleFont, buttonFont, textFont

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

-- Função para calcular dimensões dos botões responsivamente
function getButtonDimensions()
    local scale = getScale()
    return {width = math.floor(300 * scale), height = math.floor(80 * scale)}
end

-- Botões do menu principal (centralizados automaticamente)
local menuButtons = {
    {
        text = "Jogar",
        y = 0.475, -- porcentagem da altura da tela
        action = function() gameState = "difficulty" end
    }, {
        text = "Como Jogar",
        y = 0.625, -- porcentagem da altura da tela
        action = function() gameState = "instructions" end
    }
}

-- Botões da tela de dificuldade (centralizados automaticamente)
local difficultyButtons = {
    {text = "Fácil", y = 0.3125, action = function() gameState = "game" end},
    {text = "Médio", y = 0.5, action = function() gameState = "game_medium" end},
    {text = "Difícil", y = 0.6875, action = function() gameState = "game_hard" end}
}

-- Função para centralizar botões responsivamente
function centerButtons(buttons)
    local buttonDim = getButtonDimensions()
    for _, button in ipairs(buttons) do
        button.x = (screenWidth - buttonDim.width) / 2
        button.width = buttonDim.width
        button.height = buttonDim.height
        button.y = math.floor(button.y * screenHeight)
    end
end

function love.load()
    updateScreenDimensions()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("berr.io")
    backgroundImage = love.graphics.newImage("assets/fundo.jpg")
    clickSound = love.audio.newSource("assets/click_sound.mp3", "static")

    -- Carregar fontes com escala
    loadFonts()

    -- Centralizar todos os botões
    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

function love.resize(w, h)
    updateScreenDimensions()
    loadFonts()
    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    bounceTime = bounceTime + dt

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
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundImage, 0, 0, 0, screenWidth / backgroundImage:getWidth(),
                       screenHeight / backgroundImage:getHeight())

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    if gameState == "menu" then
        drawMenu()
    elseif gameState == "instructions" then
        drawInstructions()
    elseif gameState == "difficulty" then
        drawDifficulty()
    elseif gameState == "game" then
        drawGameFacil()
    elseif gameState == "game_medium" then
        drawGameMedio()
    elseif gameState == "game_hard" then
        drawGameDificil()
    end
end

function drawMenu()
    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    local text = "Trabalho final da disciplina de LP, feito em LOVE2D. ®"
    local textWidth = textFont:getWidth(text)
    love.graphics.print(text, (screenWidth - textWidth) / 2, screenHeight * 0.8375) -- 67/80 da altura

    love.graphics.setFont(titleFont)
    local titleText = "berr.io"
    local titleWidth = titleFont:getWidth(titleText)
    local titleHeight = titleFont:getHeight()
    local scale = 1 + 0.05 * math.sin(bounceTime * 3)
    local angle = math.rad(2) * math.sin(bounceTime * 2)
    local centerX = screenWidth / 2
    local centerY = screenHeight * 0.225 + titleHeight / 2 -- 18/80 da altura

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
        love.graphics.setColor(button.isHovered and colors.buttonHover or colors.button)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

function drawInstructions()
    love.graphics.setColor(colors.title)
    love.graphics.setFont(titleFont)
    local titleText = "Como Jogar"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, screenHeight * 0.0625) -- 5/80 da altura

    love.graphics.setFont(textFont)
    local instructions = {
        "   • Você terá 6 tentativas. Cada uma delas deve ser uma", "   palavra que exista.",
        "", "   • Acentos e cedilha são ignorados.", "",
        "   • Após chutar, as letras mudarão para indicar o quão",
        "   perto você está da resposta:", "",
        "   - Se a letra for VERDE, ela está presente na palavra", "   e na posição correta.",
        "", "   - Se a letra for AMARELA, ela está presente na palavra,",
        "   mas na posição errada.", "",
        "   - Se a letra for VERMELHA, ela NÃO está na palavra."
    }

    local lineHeight = textFont:getHeight() * 1.6
    for i, line in ipairs(instructions) do
        local y = screenHeight * 0.175 + (i - 1) * lineHeight
        if line:find("VERDE") then
            love.graphics.setColor(colors.green)
        elseif line:find("AMARELA") then
            love.graphics.setColor(colors.yellow)
        elseif line:find("VERMELHA") then
            love.graphics.setColor(colors.red)
        else
            love.graphics.setColor(colors.text)
        end
        love.graphics.print(line, screenWidth * 0.015, y)
    end

    love.graphics.setColor(colors.text)
    love.graphics.print("Exemplos:", screenWidth * 0.36, screenHeight * 0.7125)
    local exampleY = screenHeight * 0.75
    local squareSize = 18 * getScale()

    love.graphics.setColor(colors.green)
    love.graphics.rectangle("fill", screenWidth * 0.29, exampleY, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição correta", screenWidth * 0.336, exampleY + squareSize * 0.1)

    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", screenWidth * 0.29, exampleY + squareSize * 1.4, squareSize,
                            squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição errada", screenWidth * 0.336, exampleY + squareSize * 1.5)

    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", screenWidth * 0.29, exampleY + squareSize * 2.8, squareSize,
                            squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Não está na palavra", screenWidth * 0.318, exampleY + squareSize * 2.9)
end

function drawDifficulty()
    love.graphics.setColor(colors.title)
    love.graphics.setFont(difficultyTitleFont)
    local titleText = "Escolha a Dificuldade"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, screenHeight * 0.125) -- 10/80 da altura

    love.graphics.setFont(buttonFont)
    for _, button in ipairs(difficultyButtons) do
        love.graphics.setColor(button.isHovered and colors.buttonHover or colors.button)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height,
                                8 * getScale(), 8 * getScale())
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

-- Função para calcular dimensões da grade responsivamente
function getGridDimensions()
    local scale = getScale()
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

function drawGameFacil()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Grade 6x5 (centralizada)
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing
    local startX = (screenWidth - gridWidth) / 2
    local startY = screenHeight * 0.0625 -- 5/80 da altura

    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Teclado virtual
    drawVirtualKeyboard()
end

function drawGameMedio()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Duas grades 6x5 lado a lado
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing

    local gridSeparation = math.floor(40 * getScale()) -- separação entre as duas grades
    local totalWidth = gridWidth * 2 + gridSeparation
    local startX1 = (screenWidth - totalWidth) / 2
    local startX2 = startX1 + gridWidth + gridSeparation
    local startY = screenHeight * 0.0625 -- 5/80 da altura

    -- Desenhar primeira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX1 + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Desenhar segunda grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX2 + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Teclado virtual abaixo das grades
    drawVirtualKeyboard()
end

function drawGameDificil()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Três grades 6x5 lado a lado
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing

    local spacingBetweenGrids = math.floor(30 * getScale())
    local totalWidth = gridWidth * 3 + spacingBetweenGrids * 2

    local startX1 = (screenWidth - totalWidth) / 2
    local startX2 = startX1 + gridWidth + spacingBetweenGrids
    local startX3 = startX2 + gridWidth + spacingBetweenGrids

    local startY = screenHeight * 0.0625 -- 5/80 da altura

    -- Desenhar primeira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX1 + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Segunda grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX2 + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Terceira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX3 + col * (grid.boxSize + grid.spacing)
            local y = startY + row * (grid.boxSize + grid.spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, grid.boxSize, grid.boxSize, 4 * getScale(),
                                    4 * getScale())
        end
    end

    -- Teclado virtual
    drawVirtualKeyboard()
end

function drawVirtualKeyboard()
    local scale = getScale()
    local keyHeight = math.floor(70 * scale)
    local keyWidth = math.floor(60 * scale)
    local enterWidth = math.floor(150 * scale)
    local spacing = math.floor(12 * scale)
    local enterExtraMargin = math.floor(30 * scale) -- margem antes do ENTER
    local startY = screenHeight * 0.6125 -- posicionamento responsivo

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

        local startX = (screenWidth - totalWidth) / 2
        local x = startX

        for _, key in ipairs(row) do
            local thisKeyWidth = (key == "ENTER") and enterWidth or keyWidth
            local margin = (key == "ENTER") and enterExtraMargin or 0

            x = x + margin
            local y = startY + (rowIndex - 1) * (keyHeight + spacing)

            love.graphics.setColor(0.15, 0.15, 0.15)
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
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "instructions" or gameState == "difficulty" or gameState == "game" or
            gameState == "game_medium" or gameState == "game_hard" then
            gameState = "menu"
        else
            love.event.quit()
        end
    end
end

function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end
