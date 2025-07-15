-- Game Drawing Functions
local gameDraw = {}

function gameDraw.drawGameEasy(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                               utils, screenWidth, screenHeight, currentInput, currentRow,
                               keyboardLayout, keyboardState, showingMessage, messageText,
                               messageColor, gameState)
    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Grade 6x5 (centralizada) - tamanho maior
    local grid = utils.getGridDimensionsEasy(screenWidth, screenHeight)
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local startX = (content.width - gridWidth) / 2
    local startY = content.height * 0.12

    ui.drawGridAt(startX, startY - 15, 6, 5, grid, gameInstances.easy, colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)

    -- Teclado virtual
    ui.drawVirtualKeyboard(keyboardLayout, keyboardState, colors, buttonFont, content,
                           function() return utils.getScale(screenWidth, screenHeight) end)

    -- Mensagem
    ui.drawMessage(showingMessage, messageText, messageColor, gameState, gameInstances, colors,
                   buttonFont, buttonFont, content)
end

function gameDraw.drawGameMid(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                              utils, screenWidth, screenHeight, currentInput, currentRow,
                              keyboardLayout, keyboardState, showingMessage, messageText,
                              messageColor, gameState)
    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Duas grades 6x5 lado a lado - tamanho médio
    local grid = utils.getGridDimensionsMedium(screenWidth, screenHeight)
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local gridSeparation = math.floor(40 * utils.getScale(screenWidth, screenHeight))
    local totalWidth = gridWidth * 2 + gridSeparation
    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + gridSeparation
    local startY = content.height * 0.12

    ui.drawGridAt(startX1, startY - 15, 6, 5, grid, gameInstances.medium[1], colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)
    ui.drawGridAt(startX2, startY - 15, 6, 5, grid, gameInstances.medium[2], colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)

    -- Teclado virtual dividido para o modo médio
    ui.drawVirtualKeyboardMedium(keyboardLayout, keyboardState, colors, buttonFont, content,
                                 function() return utils.getScale(screenWidth, screenHeight) end)

    -- Mensagem
    ui.drawMessage(showingMessage, messageText, messageColor, gameState, gameInstances, colors,
                   buttonFont, buttonFont, content)
end

function gameDraw.drawGameHard(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                               utils, screenWidth, screenHeight, currentInput, currentRow,
                               keyboardLayout, keyboardState, showingMessage, messageText,
                               messageColor, gameState)
    -- Título "berr.io" no topo
    love.graphics.setFont(difficultyTitleFont)
    love.graphics.setColor(colors.title)
    local titleText = "berr.io"
    local titleWidth = difficultyTitleFont:getWidth(titleText)
    love.graphics.print(titleText, (content.width - titleWidth) / 2, content.height * 0.02)

    love.graphics.setFont(buttonFont)
    love.graphics.setColor(colors.text)

    -- Três grades 6x5 lado a lado - tamanho original (menor)
    local grid = utils.getGridDimensionsHard(screenWidth, screenHeight)
    local gridWidth = 5 * grid.boxSize + 4 * grid.spacing
    local spacingBetweenGrids = math.floor(30 * utils.getScale(screenWidth, screenHeight))
    local totalWidth = gridWidth * 3 + spacingBetweenGrids * 2

    local startX1 = (content.width - totalWidth) / 2
    local startX2 = startX1 + gridWidth + spacingBetweenGrids
    local startX3 = startX2 + gridWidth + spacingBetweenGrids

    local startY = content.height * 0.12

    ui.drawGridAt(startX1, startY - 15, 6, 5, grid, gameInstances.hard[1], colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)
    ui.drawGridAt(startX2, startY - 15, 6, 5, grid, gameInstances.hard[2], colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)
    ui.drawGridAt(startX3, startY - 15, 6, 5, grid, gameInstances.hard[3], colors, buttonFont,
                  function() return utils.getScale(screenWidth, screenHeight) end, currentInput,
                  currentRow)

    -- Teclado virtual maior para o modo difícil
    ui.drawVirtualKeyboardHard(keyboardLayout, keyboardState, colors, buttonFont, content,
                               function() return utils.getScale(screenWidth, screenHeight) end)

    -- Mensagem
    ui.drawMessage(showingMessage, messageText, messageColor, gameState, gameInstances, colors,
                   buttonFont, buttonFont, content)
end

return gameDraw
