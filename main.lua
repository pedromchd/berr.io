-- Menu berr.io com tela de instruções - Modularized version
local Berrio = require("libraries.berrio")
local config = require("config")
local utils = require("utils")
local ui = require("ui")
local gameLogic = require("gameLogic")
local gameDraw = require("gameDraw")

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
local backStates = config.backStates

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
    gameLogic.updateKeyboardStateMultiGrid(gameState, gameInstances, keyboardState)
end

-- Função para processar entrada de tecla
local function processKeyInput(key)
    currentInput, currentRow, currentCol = gameLogic.processKeyInput(key, currentInput, currentRow,
                                                                     currentCol, showingMessage,
                                                                     gameState, gameInstances,
                                                                     keyboardState, debugInfo,
                                                                     showMessage,
                                                                     updateKeyboardStateMultiGrid)
end

-- LÖVE2D callback functions
function love.load()
    love.window.setMode(screenWidth, screenHeight)
    updateScreenDimensions()
    love.window.setTitle("berr.io")
    backgroundImage = love.graphics.newImage("assets/fundo.jpg")
    clickSound = love.audio.newSource("assets/click_sound.mp3", "static")

    -- Carregar fontes com escala
    loadFonts()

    -- Criar botões dinamicamente
    local function changeState(newState) gameState = newState end

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

    if gameState == "menu" then
        for _, button in ipairs(menuButtons) do
            button.isHovered = utils.isPointInRect(mouseX, mouseY, button.x, button.y, button.width,
                                                   button.height)
        end
    elseif gameState == "difficulty" then
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

    if gameState == "menu" then
        ui.drawMenu(colors, titleFont, buttonFont, textFont, content, bounceTime, menuButtons,
                    getScale)
    elseif gameState == "instructions" then
        ui.drawInstructions(colors, titleFont, textFont, content, getScale)
    elseif gameState == "difficulty" then
        ui.drawDifficulty(colors, difficultyTitleFont, buttonFont, content, difficultyButtons,
                          getScale)
    elseif gameState == "game" then
        gameDraw.drawGameEasy(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                              utils, screenWidth, screenHeight, currentInput, currentRow,
                              keyboardLayout, keyboardState, showingMessage, messageText,
                              messageColor, gameState)
    elseif gameState == "game_medium" then
        gameDraw.drawGameMid(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                             utils, screenWidth, screenHeight, currentInput, currentRow,
                             keyboardLayout, keyboardState, showingMessage, messageText,
                             messageColor, gameState)
    elseif gameState == "game_hard" then
        gameDraw.drawGameHard(colors, difficultyTitleFont, buttonFont, content, gameInstances, ui,
                              utils, screenWidth, screenHeight, currentInput, currentRow,
                              keyboardLayout, keyboardState, showingMessage, messageText,
                              messageColor, gameState)
    end

    love.graphics.pop()

    -- Desenhar informações de debug
    ui.drawDebugInfo(showDebug, debugInfo, textFont)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if gameState == "menu" then
            for _, btn in ipairs(menuButtons) do
                if utils.isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif gameState == "difficulty" then
            for _, btn in ipairs(difficultyButtons) do
                if utils.isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)
                    btn.action()
                    break
                end
            end
        elseif gameState == "game" or gameState == "game_medium" or gameState == "game_hard" then
            -- Verificar cliques no teclado virtual
            local keyPressed = utils.getVirtualKeyPressed(x, y, gameState, keyboardLayout,
                                                          screenWidth, screenHeight)
            if keyPressed then
                love.audio.play(clickSound)
                processKeyInput(keyPressed)
            end
        end
    end
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
        -- Verificar se TODAS as grids acabaram para permitir restart
        local gameEnded = false
        if gameState == "game" then
            -- Check if easy game is done
            gameEnded = gameInstances.easy and gameInstances.easy.gameOver
        elseif gameState == "game_medium" then
            gameEnded = (gameInstances.medium[1] and gameInstances.medium[1].gameOver) and
                            (gameInstances.medium[2] and gameInstances.medium[2].gameOver)
        elseif gameState == "game_hard" then
            gameEnded = (gameInstances.hard[1] and gameInstances.hard[1].gameOver) and
                            (gameInstances.hard[2] and gameInstances.hard[2].gameOver) and
                            (gameInstances.hard[3] and gameInstances.hard[3].gameOver)
        end

        if key == "r" and gameEnded then
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
