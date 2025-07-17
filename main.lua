local Berrio = require("src.libs.berrio")
local config = require("src.modules.config")
local utils = require("src.modules.utils")
local ui = require("src.modules.ui")
local gameLogic = require("src.modules.gameLogic")
local gameDraw = require("src.modules.gameDraw")
local assetManager = require("src.systems.assetManager")
local stateManager = require("src.systems.stateManager")

local bounceTime = 0
local gameInstances = {easy = nil, medium = {}, hard = {}}
local currentInput = ""
local currentRow = 1
local currentCol = 1
local showingMessage = false
local messageText = ""
local messageTime = 0
local messageColor = "text"
local keyboardState = {}
local debugInfo = {}
local showDebug = false
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
local backgroundImage
local clickSound
local invalidGuessSound
local winSound
local backspaceSound
local enterSound
local titleFont, difficultyTitleFont, buttonFont, textFont

local colors = config.colors
local keyboardLayout = config.keyboardLayout
local menuButtons
local difficultyButtons

-- Atualiza dimensões da tela
local function updateScreenDimensions() screenWidth, screenHeight = utils.updateScreenDimensions() end

-- Obtém escala para interface responsiva
local function getScale() return utils.getScale(screenWidth, screenHeight) end

-- Obtém área centralizada de conteúdo
local function getContentArea() return utils.getContentArea(screenWidth, screenHeight) end

-- Carrega fontes com escala adequada
local function loadFonts()
    titleFont, difficultyTitleFont, buttonFont, textFont =
        utils.loadFonts(screenWidth, screenHeight)
end

-- Centraliza botões na tela
local function centerButtons(buttons) utils.centerButtons(buttons, screenWidth, screenHeight) end

-- Inicializa uma nova partida
local function initGame(difficulty)
    gameLogic.initGame(difficulty, gameInstances, Berrio)

    currentInput = ""
    currentRow = 1
    currentCol = 1
    showingMessage = false
    messageText = ""
    messageTime = 0

    keyboardState = {}
end

-- Exibe mensagem temporária na tela
local function showMessage(text, color, duration)
    messageText = text
    messageColor = color
    messageTime = duration
    showingMessage = true
end

-- Atualiza estado das teclas do teclado virtual
local function updateKeyboardStateMultiGrid()
    gameLogic.updateKeyboardStateMultiGrid(stateManager.getState(), gameInstances, keyboardState)
end

-- Processa entrada de tecla do jogador
local function processKeyInput(key)
    currentInput, currentRow, currentCol = gameLogic.processKeyInput(key, currentInput, currentRow,
                                                                     currentCol, showingMessage,
                                                                     stateManager.getState(),
                                                                     gameInstances, keyboardState,
                                                                     debugInfo, showMessage,
                                                                     updateKeyboardStateMultiGrid)
end

-- Inicia o jogo
function love.load()
    love.window.setMode(screenWidth, screenHeight)
    updateScreenDimensions()
    love.window.setTitle("berr.io")

    assetManager.loadAll()
    backgroundImage = assetManager.getImage("background")
    clickSound = assetManager.getSound("click")
    invalidGuessSound = assetManager.getSound("invalid_guess")
    winSound = assetManager.getSound("win")
    backspaceSound = assetManager.getSound("backspace")
    enterSound = assetManager.getSound("enter")

    loadFonts()

    local function changeState(newState) stateManager.setState(newState) end

    menuButtons = config.createMenuButtons()
    difficultyButtons = config.createDifficultyButtons(initGame)

    for _, button in ipairs(menuButtons) do
        local originalAction = button.action
        button.action = function() originalAction(changeState) end
    end
    for _, button in ipairs(difficultyButtons) do
        local originalAction = button.action
        button.action = function() originalAction(changeState) end
    end

    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

function love.resize(w, h)
    updateScreenDimensions()
    loadFonts()
    centerButtons(menuButtons)
    centerButtons(difficultyButtons)
end

-- Atualiza a cada frame
function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()
    bounceTime = bounceTime + dt

    if showingMessage then
        messageTime = messageTime - dt
        if messageTime <= 0 then showingMessage = false end
    end

    if stateManager.getState() == "menu" then
        for _, button in ipairs(menuButtons) do
            button.isHovered = utils.isPointInRect(mouseX, mouseY, button.x, button.y, button.width,
                                                   button.height)
        end
    elseif stateManager.getState() == "difficulty" then
        for _, button in ipairs(difficultyButtons) do
            button.isHovered = utils.isPointInRect(mouseX, mouseY, button.x, button.y, button.width,
                                                   button.height)
        end
    end
end

-- Desenha na tela
function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(backgroundImage, 0, 0, 0, screenWidth / backgroundImage:getWidth(),
                       screenHeight / backgroundImage:getHeight())

    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)

    local content = getContentArea()
    love.graphics.push()
    love.graphics.translate(content.x, content.y)

    if stateManager.getState() == "menu" then
        ui.drawMenu(colors, titleFont, buttonFont, textFont, content, bounceTime, menuButtons,
                    getScale)
    elseif stateManager.getState() == "instructions" then
        ui.drawInstructions(colors, titleFont, textFont, content, getScale)
    elseif stateManager.getState() == "difficulty" then
        ui.drawDifficulty(colors, difficultyTitleFont, buttonFont, content, difficultyButtons,
                          getScale)
    elseif stateManager.getState() == "game" then
        gameDraw.drawGameEasy(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                              utils, screenWidth, screenHeight, currentInput, currentRow,
                              keyboardLayout, keyboardState, showingMessage, messageText,
                              messageColor, stateManager.getState())
    elseif stateManager.getState() == "game_medium" then
        gameDraw.drawGameMedium(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                                utils, screenWidth, screenHeight, currentInput, currentRow,
                                keyboardLayout, keyboardState, showingMessage, messageText,
                                messageColor, stateManager.getState())
    elseif stateManager.getState() == "game_hard" then
        gameDraw.drawGameHard(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                              utils, screenWidth, screenHeight, currentInput, currentRow,
                              keyboardLayout, keyboardState, showingMessage, messageText,
                              messageColor, stateManager.getState())
    end

    love.graphics.pop()

    ui.drawDebugInfo(showDebug, debugInfo, textFont)
end

-- Cliques do mouse
function love.mousepressed(x, y, button)
    if button == 1 then
        if stateManager.getState() == "menu" then
            for _, btn in ipairs(menuButtons) do
                if utils.isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif stateManager.getState() == "difficulty" then
            for _, btn in ipairs(difficultyButtons) do
                if utils.isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif stateManager.isGameState() then
            local keyPressed = utils.getVirtualKeyPressed(x, y, stateManager.getState(),
                                                          keyboardLayout, screenWidth, screenHeight)
            if keyPressed then
                -- Don't play click sound for backspace or enter, they will be handled in processKeyInput
                -- Click sound for letter keys will also be handled in processKeyInput
                if keyPressed ~= "backspace" and keyPressed ~= "return" and not keyPressed:match("^%a$") then
                    love.audio.play(clickSound)
                end
                processKeyInput(keyPressed)
            end
        end
    end
end

-- Teclas pressionadas
function love.keypressed(key)
    if key == "escape" then
        local backState = stateManager.getBackState()
        if backState then
            stateManager.setState(backState)
        else
            love.event.quit()
        end
    elseif key == "f1" then
        showDebug = not showDebug
    elseif stateManager.isGameState() then
        local gameEnded = false
        local currentState = stateManager.getState()
        if currentState == "game" then
            local easyGame = gameInstances.easy
            gameEnded = easyGame and easyGame.gameOver or false
        elseif currentState == "game_medium" then
            gameEnded = (gameInstances.medium[1] and gameInstances.medium[1].gameOver) and
                            (gameInstances.medium[2] and gameInstances.medium[2].gameOver)
        elseif currentState == "game_hard" then
            gameEnded = (gameInstances.hard[1] and gameInstances.hard[1].gameOver) and
                            (gameInstances.hard[2] and gameInstances.hard[2].gameOver) and
                            (gameInstances.hard[3] and gameInstances.hard[3].gameOver)
        end

        if key == "r" and gameEnded then
            if currentState == "game" then
                initGame("easy")
            elseif currentState == "game_medium" then
                initGame("medium")
            elseif currentState == "game_hard" then
                initGame("hard")
            end
        else
            processKeyInput(key)
        end
    end
end
