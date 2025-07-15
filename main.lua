-- Menu berr.io com tela de instruções - Modularized version
local Berrio = require("src.libs.berrio")
local config = require("src.modules.config")
local utils = require("src.modules.utils")
local ui = require("src.modules.ui")
local gameLogic = require("src.modules.gameLogic")
local gameDraw = require("src.modules.gameDraw")
local assetManager = require("src.systems.assetManager")
local stateManager = require("src.systems.stateManager")

-- Estados da tela
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

-- Estado das teclas do teclado
local keyboardState = {}

-- Debug info
local debugInfo = {}
local showDebug = false

-- Configurações da tela
local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()

-- Imagem de fundo
local backgroundImage
local clickSound

-- Fontes responsivas
local titleFont, difficultyTitleFont, buttonFont, textFont

-- Configurações importadas
local colors = config.colors
local keyboardLayout = config.keyboardLayout

-- Botões criados dinamicamente
local menuButtons
local difficultyButtons

-- Helper functions using the modularized utilities
local function updateScreenDimensions() screenWidth, screenHeight = utils.updateScreenDimensions() end

local function getScale() return utils.getScale(screenWidth, screenHeight) end

local function getContentArea() return utils.getContentArea(screenWidth, screenHeight) end

local function loadFonts()
    titleFont, difficultyTitleFont, buttonFont, textFont =
        utils.loadFonts(screenWidth, screenHeight)
end

local function centerButtons(buttons) utils.centerButtons(buttons, screenWidth, screenHeight) end

-- Função para inicializar o jogo
local function initGame(difficulty)
    gameLogic.initGame(difficulty, gameInstances, Berrio)

    -- Reset input state
    currentInput = ""
    currentRow = 1
    currentCol = 1
    showingMessage = false
    messageText = ""
    messageTime = 0

    -- Reset keyboard state
    keyboardState = {}
end

-- Função para mostrar mensagem temporária
local function showMessage(text, color, duration)
    messageText = text
    messageColor = color
    messageTime = duration
    showingMessage = true
end

-- Função para atualizar estado do teclado
local function updateKeyboardStateMultiGrid()
    gameLogic.updateKeyboardStateMultiGrid(stateManager.getState(), gameInstances, keyboardState)
end

-- Função para processar entrada de tecla
local function processKeyInput(key)
    currentInput, currentRow, currentCol = gameLogic.processKeyInput(key, currentInput, currentRow,
                                                                     currentCol, showingMessage,
                                                                     stateManager.getState(),
                                                                     gameInstances, keyboardState,
                                                                     debugInfo, showMessage,
                                                                     updateKeyboardStateMultiGrid)
end

-- LÖVE2D callback functions
function love.load()
    love.window.setMode(screenWidth, screenHeight)
    updateScreenDimensions()
    love.window.setTitle("berr.io")

    -- Load all assets using asset manager
    assetManager.loadAll()
    backgroundImage = assetManager.getImage("background")
    clickSound = assetManager.getSound("click")

    -- Carregar fontes com escala
    loadFonts()

    -- Criar botões dinamicamente
    local function changeState(newState) stateManager.setState(newState) end

    menuButtons = config.createMenuButtons()
    difficultyButtons = config.createDifficultyButtons(initGame)

    -- Set the changeState function for the buttons
    for _, button in ipairs(menuButtons) do
        local originalAction = button.action
        button.action = function() originalAction(changeState) end
    end
    for _, button in ipairs(difficultyButtons) do
        local originalAction = button.action
        button.action = function() originalAction(changeState) end
    end

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

    -- Atualizar timer de mensagem
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

    -- Desenhar informações de debug
    ui.drawDebugInfo(showDebug, debugInfo, textFont)
end

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
            -- Verificar cliques no teclado virtual
            local keyPressed = utils.getVirtualKeyPressed(x, y, stateManager.getState(),
                                                          keyboardLayout, screenWidth, screenHeight)
            if keyPressed then
                love.audio.play(clickSound)
                processKeyInput(keyPressed)
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        local backState = stateManager.getBackState()
        if backState then
            stateManager.setState(backState)
        else
            love.event.quit()
        end
    elseif key == "f1" then
        -- Toggle debug mode
        showDebug = not showDebug
    elseif stateManager.isGameState() then
        -- Verificar se TODAS as grids acabaram para permitir restart
        local gameEnded = false
        local currentState = stateManager.getState()
        if currentState == "game" then
            -- Check if easy game is done
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
            -- Reiniciar o jogo
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
