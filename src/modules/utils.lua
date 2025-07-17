local utils = {}

-- Atualiza dimensões da tela
function utils.updateScreenDimensions() return love.graphics.getWidth(), love.graphics.getHeight() end

-- Calcula escala horizontal
function utils.getScaleX(screenWidth) return screenWidth / 1100 end

-- Calcula escala vertical
function utils.getScaleY(screenHeight) return screenHeight / 800 end

-- Calcula escala responsiva mantendo proporção
function utils.getScale(screenWidth, screenHeight)
    return math.min(utils.getScaleX(screenWidth), utils.getScaleY(screenHeight))
end

-- Calcula dimensões da grade padrão
function utils.getGridDimensions(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

-- Calcula dimensões da grade no modo fácil
function utils.getGridDimensionsEasy(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
    return {boxSize = math.floor(70 * scale), spacing = math.floor(12 * scale)}
end

-- Calcula dimensões da grade no modo médio
function utils.getGridDimensionsMedium(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
    return {boxSize = math.floor(70 * scale), spacing = math.floor(11 * scale)}
end

-- Calcula dimensões da grade no modo difícil
function utils.getGridDimensionsHard(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
    return {boxSize = math.floor(60 * scale), spacing = math.floor(10 * scale)}
end

-- Calcula área de conteúdo centralizada
function utils.getContentArea(screenWidth, screenHeight)
    local maxContentWidth = 1100
    local maxContentHeight = 800
    local scale = utils.getScale(screenWidth, screenHeight)

    local contentWidth = math.min(screenWidth, maxContentWidth * scale)
    local contentHeight = math.min(screenHeight, maxContentHeight * scale)

    local offsetX = (screenWidth - contentWidth) / 2
    local offsetY = (screenHeight - contentHeight) / 2

    return {x = offsetX, y = offsetY, width = contentWidth, height = contentHeight, scale = scale}
end

-- Carrega fontes com escala adequada
function utils.loadFonts(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)

    local titleFontSize = 60
    local difficultyTitleFontSize = 40
    local buttonFontSize = 30
    local textFontSize = 18

    local assetManager = require("src.systems.assetManager")
    
    local titleFont = assetManager.loadFont("titleFont", "assets/fonts/PressStart2P-Regular.ttf", math.floor(titleFontSize * scale))
    local difficultyTitleFont = assetManager.loadFont("difficultyTitleFont", "assets/fonts/PressStart2P-Regular.ttf", math.floor(difficultyTitleFontSize * scale))
    local buttonFont = assetManager.loadFont("buttonFont", "assets/fonts/PressStart2P-Regular.ttf", math.floor(buttonFontSize * scale))
    local textFont = assetManager.loadFont("textFont", "assets/fonts/PressStart2P-Regular.ttf", math.floor(textFontSize * scale))

    return titleFont, difficultyTitleFont, buttonFont, textFont
end

-- Calcula dimensões dos botões
function utils.getButtonDimensions(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
    return {width = math.floor(350 * scale), height = math.floor(100 * scale)}
end

-- Centraliza botões na tela
function utils.centerButtons(buttons, screenWidth, screenHeight)
    local buttonDim = utils.getButtonDimensions(screenWidth, screenHeight)
    local content = utils.getContentArea(screenWidth, screenHeight)

    for _, button in ipairs(buttons) do
        if not button.relativeY and button.y then button.relativeY = button.y end
        button.x = content.x + (content.width - buttonDim.width) / 2
        button.width = buttonDim.width
        button.height = buttonDim.height
        button.y = content.y + math.floor((button.relativeY or 0) * content.height)
    end
end

-- Detecta cliques no teclado virtual
function utils.getVirtualKeyPressed(mouseX, mouseY, gameState, keyboardLayout, screenWidth,
                                    screenHeight)
    local content = utils.getContentArea(screenWidth, screenHeight)
    local scale = utils.getScale(screenWidth, screenHeight)
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

            if utils.isPointInRect(mouseX, mouseY, x, y, thisKeyWidth, keyHeight) then
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

-- Verifica se um ponto está dentro de um retângulo
function utils.isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

return utils
