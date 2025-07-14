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
    local content = getContentArea()

    for _, button in ipairs(buttons) do
        button.x = content.x + (content.width - buttonDim.width) / 2
        button.width = buttonDim.width
        button.height = buttonDim.height
        button.y = content.y + math.floor(button.y * content.height)
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
        drawGameFacil()
    elseif gameState == "game_medium" then
        drawGameMedio()
    elseif gameState == "game_hard" then
        drawGameDificil()
    end

    love.graphics.pop()
end

function drawMenu()
    local content = getContentArea()

    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    local text = "Trabalho final da disciplina de LP, feito em LOVE2D. ®"
    local textWidth = textFont:getWidth(text)
    love.graphics.print(text, (content.width - textWidth) / 2, content.height * 0.8375)

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
        "• Você terá 6 tentativas. Cada uma delas deve ser uma palavra que exista.", "",
        "• Acentos e cedilha são ignorados.", "",
        "• Após chutar, as letras mudarão para indicar o quão perto você está da resposta:",
        "", "- Se a letra for VERDE, ela está presente na palavra e na posição correta.", "",
        "- Se a letra for AMARELA, ela está presente na palavra, mas na posição errada.", "",
        "- Se a letra for VERMELHA, ela NÃO está na palavra."
    }

    local lineHeight = textFont:getHeight() * 1.4
    local startY = content.height * 0.22
    local maxTextWidth = content.width - padding * 2
    local currentY = startY

    for _, line in ipairs(instructions) do
        if line == "" then
            currentY = currentY + lineHeight * 0.5
        else
            local wrappedLines = wrapText(line, textFont, maxTextWidth)
            for _, wrappedLine in ipairs(wrappedLines) do
                if wrappedLine:find("VERDE") then
                    love.graphics.setColor(colors.green)
                elseif wrappedLine:find("AMARELA") then
                    love.graphics.setColor(colors.yellow)
                elseif wrappedLine:find("VERMELHA") then
                    love.graphics.setColor(colors.red)
                else
                    love.graphics.setColor(colors.text)
                end
                love.graphics.print(wrappedLine, padding, currentY)
                currentY = currentY + lineHeight
            end
        end
    end

    -- Seção de exemplos mais abaixo
    local examplesY = content.height * 0.65
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
    love.graphics.print("Posição correta", exampleCenterX - 100 * getScale(), exampleStartY + 2)

    -- Exemplo Amarelo
    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", exampleCenterX - 150 * getScale(),
                            exampleStartY + squareSize * 1.8, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição errada", exampleCenterX - 100 * getScale(),
                        exampleStartY + squareSize * 1.8 + 2)

    -- Exemplo Vermelho
    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", exampleCenterX - 150 * getScale(),
                            exampleStartY + squareSize * 3.6, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Não está na palavra", exampleCenterX - 100 * getScale(),
                        exampleStartY + squareSize * 3.6 + 2)

    -- Instrução para voltar
    love.graphics.setColor(colors.text)
    local backText = "Pressione ESC para voltar"
    local backTextWidth = textFont:getWidth(backText)
    love.graphics.print(backText, (content.width - backTextWidth) / 2, content.height * 0.9)
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

-- Função para calcular dimensões da grade responsivamente
function getGridDimensions()
    local scale = getScale()
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

function drawGameFacil()
    local content = getContentArea()

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Grade 6x5 (centralizada)
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing
    local startX = (content.width - gridWidth) / 2
    local startY = content.height * 0.08

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
    local content = getContentArea()

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Duas grades 6x5 lado a lado
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing

    local gridSeparation = math.floor(40 * getScale())
    local totalWidth = gridWidth * 2 + gridSeparation
    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + gridSeparation
    local startY = content.height * 0.08

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
    local content = getContentArea()

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Três grades 6x5 lado a lado
    local grid = getGridDimensions()
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridHeight = 6 * grid.boxSize + 5 * grid.spacing

    local spacingBetweenGrids = math.floor(30 * getScale())
    local totalWidth = gridWidth * 3 + spacingBetweenGrids * 2

    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + spacingBetweenGrids
    local startX3 = startX2 + gridWidth + spacingBetweenGrids

    local startY = content.height * 0.08

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
    local content = getContentArea()
    local scale = getScale()
    local keyHeight = math.floor(70 * scale)
    local keyWidth = math.floor(60 * scale)
    local enterWidth = math.floor(150 * scale)
    local spacing = math.floor(12 * scale)
    local enterExtraMargin = math.floor(30 * scale)
    local startY = content.height * 0.62 -- posicionamento responsivo

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
