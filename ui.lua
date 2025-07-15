-- UI and Drawing Functions
local ui = {}

-- Função para quebrar texto conforme largura disponível
function ui.wrapText(text, font, maxWidth)
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

function ui.drawMenu(colors, titleFont, buttonFont, textFont, content, bounceTime, menuButtons,
                     getScale)
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

function ui.drawInstructions(colors, titleFont, textFont, content, getScale)
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
        local wrappedLines = ui.wrapText(instruction.text, textFont, maxTextWidth)

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

function ui.drawDifficulty(colors, difficultyTitleFont, buttonFont, content, difficultyButtons,
                           getScale)
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
function ui.drawGridAt(startX, startY, rows, cols, gridDimensions, gameInstance, colors, buttonFont,
                       getScale, currentInput, currentRow)
    local grid = gridDimensions
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
                elseif attemptIndex == currentRow and not gameInstance.gameOver then
                    -- Linha atual sendo digitada (apenas em grids que ainda estão ativas)
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
function ui.drawMessage(showingMessage, messageText, messageColor, gameState, gameInstances, colors,
                        buttonFont, textFont, content)
    if not showingMessage then
        -- Mostrar instrução de reiniciar se TODAS as grids acabaram
        local gameEnded = false
        if gameState == "game" then
            gameEnded = gameInstances.easy.gameOver
        elseif gameState == "game_medium" then
            gameEnded = gameInstances.medium[1].gameOver and gameInstances.medium[2].gameOver
        elseif gameState == "game_hard" then
            gameEnded = gameInstances.hard[1].gameOver and gameInstances.hard[2].gameOver and
                            gameInstances.hard[3].gameOver
        end

        if gameEnded then
            love.graphics.setFont(textFont)

            local restartText = "Pressione R para jogar novamente ou ESC para voltar ao menu"
            local textWidth = textFont:getWidth(restartText)
            local textHeight = textFont:getHeight()
            local x = (content.width - textWidth) / 2
            local y = content.height * 0.90

            -- Fundo da mensagem de restart
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle("fill", x - 25, y - 15, textWidth + 50, textHeight + 30, 10)

            -- Texto da mensagem de restart
            love.graphics.setColor(colors.text)
            love.graphics.print(restartText, x, y)
        end
        return
    end

    love.graphics.setFont(buttonFont)

    local textWidth = buttonFont:getWidth(messageText)
    local textHeight = buttonFont:getHeight()
    local x = (content.width - textWidth) / 2
    local y = content.height * 0.85

    -- Fundo da mensagem com padding maior para garantir visibilidade
    love.graphics.setColor(0, 0, 0, 0.8)
    love.graphics.rectangle("fill", x - 25, y - 15, textWidth + 50, textHeight + 30, 10)

    -- Texto da mensagem
    love.graphics.setColor(colors[messageColor] or colors.text)
    love.graphics.print(messageText, x, y)
end

function ui.drawVirtualKeyboard(keyboardLayout, keyboardState, colors, buttonFont, content, getScale)
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

function ui.drawVirtualKeyboardHard(keyboardLayout, keyboardState, colors, buttonFont, content,
                                    getScale)
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

-- Função para desenhar informações de debug
function ui.drawDebugInfo(showDebug, debugInfo, textFont)
    if not showDebug or not debugInfo.word then return end

    love.graphics.setFont(textFont)
    love.graphics.setColor(1, 1, 0) -- Amarelo

    local y = 10
    local lineHeight = textFont:getHeight() + 2

    love.graphics.print("=== DEBUG INFO (Press F1 to toggle) ===", 10, y)
    y = y + lineHeight * 2

    love.graphics.print("Palavra digitada: " .. debugInfo.word, 10, y)
    y = y + lineHeight

    love.graphics.print("Game State: " .. debugInfo.gameState, 10, y)
    y = y + lineHeight

    love.graphics.print("Total grids: " .. debugInfo.gridCount, 10, y)
    y = y + lineHeight

    love.graphics.print("Overall Won: " .. tostring(debugInfo.overallWon), 10, y)
    y = y + lineHeight

    love.graphics.print("Overall Game Over: " .. tostring(debugInfo.overallGameOver), 10, y)
    y = y + lineHeight * 2

    -- Mostrar informações de cada grid
    for i = 1, debugInfo.gridCount do
        love.graphics.setColor(0, 1, 1) -- Ciano para destacar cada grid
        love.graphics.print("--- GRID " .. i .. " ---", 10, y)
        y = y + lineHeight

        love.graphics.setColor(1, 1, 0) -- Voltar ao amarelo
        love.graphics.print("Resposta: " .. (debugInfo.allAnswers[i] or "N/A"), 10, y)
        y = y + lineHeight

        local result = debugInfo.allResults[i]
        if result then
            love.graphics.print("Won: " .. tostring(result.won), 10, y)
            y = y + lineHeight

            love.graphics.print("Game Over: " .. tostring(result.gameOver), 10, y)
            y = y + lineHeight

            love.graphics.print("Perfect Match: " ..
                                    tostring(result.match and result.match.perfect or false), 10, y)
            y = y + lineHeight

            love.graphics.print("Success: " .. tostring(result.success), 10, y)
            y = y + lineHeight

            if result.match and result.match.letters then
                love.graphics.print("Match Details:", 10, y)
                y = y + lineHeight

                -- Garantir que mostramos todos os 5 resultados
                for j = 1, 5 do
                    local letter = debugInfo.word:sub(j, j)
                    local letterResult = result.match.letters[j]
                    local resultText = "nil"
                    if letterResult == true then
                        resultText = "TRUE"
                    elseif letterResult == false then
                        resultText = "FALSE"
                    end
                    love.graphics.print("  " .. j .. ": " .. letter .. " -> " .. resultText, 10, y)
                    y = y + lineHeight
                end
            end
        end

        y = y + lineHeight -- Espaço entre grids
    end
end

return ui
