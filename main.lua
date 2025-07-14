-- Menu berr.io com tela de instruções
local menu = {}

-- Estados da tela
local gameState = "menu" -- "menu", "instructions", "difficulty", "game"
local bounceTime = 0

-- Configurações da tela
local screenWidth, screenHeight = 1100, 800

-- Imagem de fundo
local backgroundImage

-- Fontes
local titleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 60)
local difficultyTitleFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 40)
local buttonFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 25)
local textFont = love.graphics.newFont("assets/PressStart2P-Regular.ttf", 15)

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
        y = 380,
        width = 300,
        height = 80,
        action = function() gameState = "difficulty" end
    }, {
        text = "Como Jogar",
        y = 500,
        width = 300,
        height = 80,
        action = function() gameState = "instructions" end
    }
}

-- Botões da tela de dificuldade (centralizados automaticamente)
local difficultyButtons = {
    {text = "Fácil", y = 250, width = 300, height = 80, action = function() gameState = "game" end},
    {text = "Médio", y = 400, width = 300, height = 80, action = function() gameState = "game_medium" end},
    {text = "Difícil", y = 550, width = 300, height = 80, action = function() gameState = "game_hard" end}
}

-- Função para centralizar botões
function centerButtons(buttons)
    for _, button in ipairs(buttons) do button.x = (screenWidth - button.width) / 2 end
end

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("berr.io")
    backgroundImage = love.graphics.newImage("assets/fundo.jpg")
    clickSound = love.audio.newSource("assets/click_sound.mp3", "static")

    -- Centralizar todos os botões
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
    love.graphics.print(text, (screenWidth - textWidth) / 2, 670)

    love.graphics.setFont(titleFont)
    local titleText = "berr.io"
    local titleWidth = titleFont:getWidth(titleText)
    local titleHeight = titleFont:getHeight()
    local scale = 1 + 0.05 * math.sin(bounceTime * 3)
    local angle = math.rad(2) * math.sin(bounceTime * 2)
    local centerX = screenWidth / 2
    local centerY = 180 + titleHeight / 2

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
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8, 8)
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8, 8)
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
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, 50)

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

    for i, line in ipairs(instructions) do
        local y = 140 + (i - 1) * 26
        if line:find("VERDE") then
            love.graphics.setColor(colors.green)
        elseif line:find("AMARELA") then
            love.graphics.setColor(colors.yellow)
        elseif line:find("VERMELHA") then
            love.graphics.setColor(colors.red)
        else
            love.graphics.setColor(colors.text)
        end
        love.graphics.print(line, 15, y)
    end

    love.graphics.setColor(colors.text)
    love.graphics.print("Exemplos:", 400, 570)
    local exampleY = 600
    local squareSize = 18

    love.graphics.setColor(colors.green)
    love.graphics.rectangle("fill", 320, exampleY, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição correta", 370, exampleY + 2)

    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", 320, exampleY + 25, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição errada", 370, exampleY + 27)

    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", 320, exampleY + 50, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Não está na palavra", 350, exampleY + 52)
end

function drawDifficulty()
    love.graphics.setColor(colors.title)
    love.graphics.setFont(difficultyTitleFont)
    local titleText = "Escolha a Dificuldade"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, 100)

    love.graphics.setFont(buttonFont)
    for _, button in ipairs(difficultyButtons) do
        love.graphics.setColor(button.isHovered and colors.buttonHover or colors.button)
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8, 8)
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8, 8)
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

function drawGameFacil()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Grade 6x5 (centralizada)
    local boxSize = 60
    local spacing = 10
    local gridWidth = 5 * boxSize + 4 * spacing
    local gridHeight = 6 * boxSize + 5 * spacing
    local startX = (screenWidth - gridWidth) / 2
    local startY = 50

    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Teclado virtual
    drawVirtualKeyboard()
end

function drawGameMedio()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Duas grades 6x5 lado a lado
    local boxSize = 60
    local spacing = 10
    local gridWidth = 5 * boxSize + 4 * spacing
    local gridHeight = 6 * boxSize + 5 * spacing

    local totalWidth = gridWidth * 2 + 40  -- 40px de separação entre as duas grades
    local startX1 = (screenWidth - totalWidth) / 2
    local startX2 = startX1 + gridWidth + 40
    local startY = 50

    -- Desenhar primeira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX1 + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Desenhar segunda grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX2 + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Teclado virtual abaixo das grades
    drawVirtualKeyboard()
end

function drawGameDificil()
    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Três grades 6x5 lado a lado
    local boxSize = 60
    local spacing = 10
    local gridWidth = 5 * boxSize + 4 * spacing
    local gridHeight = 6 * boxSize + 5 * spacing

    local spacingBetweenGrids = 30
    local totalWidth = gridWidth * 3 + spacingBetweenGrids * 2

    local startX1 = (screenWidth - totalWidth) / 2
    local startX2 = startX1 + gridWidth + spacingBetweenGrids
    local startX3 = startX2 + gridWidth + spacingBetweenGrids

    local startY = 50

    -- Desenhar primeira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX1 + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Segunda grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX2 + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Terceira grade
    for row = 0, 5 do
        for col = 0, 4 do
            local x = startX3 + col * (boxSize + spacing)
            local y = startY + row * (boxSize + spacing)
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", x, y, boxSize, boxSize, 4, 4)
            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, boxSize, boxSize, 4, 4)
        end
    end

    -- Teclado virtual
    drawVirtualKeyboard()
end

function drawVirtualKeyboard()
    local keyHeight = 70
    local keyWidth = 60
    local enterWidth = 150
    local spacing = 12
    local enterExtraMargin = 30 -- margem antes do ENTER
    local startY = 490 -- subir um pouco por causa da tela maior

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
            love.graphics.rectangle("fill", x, y, thisKeyWidth, keyHeight, 6, 6)

            love.graphics.setColor(colors.border)
            love.graphics.rectangle("line", x, y, thisKeyWidth, keyHeight, 6, 6)

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
        if gameState == "instructions" or gameState == "difficulty" or gameState == "game" or gameState == "game_medium" or gameState == "game_hard" then
            gameState = "menu"
        else
            love.event.quit()
        end
    end
end

function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end
