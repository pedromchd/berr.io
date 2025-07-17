local gameLogic = {}

local assetManager = require("src.systems.assetManager")

-- Inicializa uma nova partida com a dificuldade selecionada
function gameLogic.initGame(difficulty, gameInstances, Berrio)
    local dataPaths = assetManager.getGameDataPaths()

    if difficulty == "easy" then
        gameInstances.easy = Berrio:new(dataPaths.answers, dataPaths.guesses)
    elseif difficulty == "medium" then
        gameInstances.medium = {
            Berrio:new(dataPaths.answers, dataPaths.guesses),
            Berrio:new(dataPaths.answers, dataPaths.guesses)
        }
    elseif difficulty == "hard" then
        gameInstances.hard = {
            Berrio:new(dataPaths.answers, dataPaths.guesses),
            Berrio:new(dataPaths.answers, dataPaths.guesses),
            Berrio:new(dataPaths.answers, dataPaths.guesses)
        }
    end
end

-- Processa entrada de tecla do jogador
function gameLogic.processKeyInput(key, currentInput, currentRow, currentCol, showingMessage,
                                   gameState, gameInstances, keyboardState, debugInfo, showMessage,
                                   updateKeyboardStateMultiGrid)
    if showingMessage then return currentInput, currentRow, currentCol end

    local hasActiveGame = false
    if gameState == "game" then
        hasActiveGame = not gameInstances.easy.gameOver
    elseif gameState == "game_medium" then
        for i = 1, 2 do
            if not gameInstances.medium[i].gameOver then
                hasActiveGame = true
                break
            end
        end
    elseif gameState == "game_hard" then
        for i = 1, 3 do
            if not gameInstances.hard[i].gameOver then
                hasActiveGame = true
                break
            end
        end
    end

    if not hasActiveGame then return currentInput, currentRow, currentCol end

    if key == "backspace" or key == "←" then
        if #currentInput > 0 then
            -- Play backspace sound
            local backspaceSound = assetManager.getSound("backspace")
            if backspaceSound then
                love.audio.play(backspaceSound)
            end
            
            currentInput = currentInput:sub(1, -2)
            currentCol = math.max(1, currentCol - 1)
        end
    elseif key == "return" or key == "enter" or key == "ENTER" then
        -- Play enter sound
        local enterSound = assetManager.getSound("enter")
        if enterSound then
            love.audio.play(enterSound)
        end
        
        if #currentInput == 5 then
            local results = {}
            local anyGameOver = false

            if gameState == "game" then
                if not gameInstances.easy.gameOver then
                    local result = gameInstances.easy:makeGuess(currentInput)
                    results[1] = result
                    anyGameOver = result.gameOver and not result.won
                end
            elseif gameState == "game_medium" then
                for i = 1, 2 do
                    if not gameInstances.medium[i].gameOver then
                        local result = gameInstances.medium[i]:makeGuess(currentInput)
                        results[i] = result
                        if result.gameOver and not result.won then
                            anyGameOver = true
                        end
                    end
                end
            elseif gameState == "game_hard" then
                for i = 1, 3 do
                    if not gameInstances.hard[i].gameOver then
                        local result = gameInstances.hard[i]:makeGuess(currentInput)
                        results[i] = result
                        if result.gameOver and not result.won then
                            anyGameOver = true
                        end
                    end
                end
            end

            local allWon = true
            if gameState == "game" then
                allWon = gameInstances.easy.won or false
            elseif gameState == "game_medium" then
                for i = 1, 2 do
                    if not gameInstances.medium[i].won then
                        allWon = false
                        break
                    end
                end
            elseif gameState == "game_hard" then
                for i = 1, 3 do
                    if not gameInstances.hard[i].won then
                        allWon = false
                        break
                    end
                end
            end

            local allAnswers = {}
            local allResults = {}
            if gameState == "game" then
                allAnswers[1] = gameInstances.easy.currentAnswer
                allResults[1] = results[1]
            elseif gameState == "game_medium" then
                for i = 1, 2 do
                    allAnswers[i] = gameInstances.medium[i].currentAnswer
                    allResults[i] = results[i]
                end
            elseif gameState == "game_hard" then
                for i = 1, 3 do
                    allAnswers[i] = gameInstances.hard[i].currentAnswer
                    allResults[i] = results[i]
                end
            end

            debugInfo.word = currentInput
            debugInfo.gameState = gameState
            debugInfo.allAnswers = allAnswers
            debugInfo.allResults = allResults
            debugInfo.overallWon = allWon
            debugInfo.overallGameOver = anyGameOver
            debugInfo.gridCount = #allAnswers

            local anyValidMove = false
            for _, result in pairs(results) do
                if result and result.success then
                    anyValidMove = true
                    break
                end
            end

            if anyValidMove then
                currentRow = currentRow + 1
                currentInput = ""
                currentCol = 1

                updateKeyboardStateMultiGrid()

                local allGridsFinished = true
                if gameState == "game" then
                    allGridsFinished = gameInstances.easy.gameOver
                elseif gameState == "game_medium" then
                    allGridsFinished = gameInstances.medium[1].gameOver and
                                           gameInstances.medium[2].gameOver
                elseif gameState == "game_hard" then
                    allGridsFinished = gameInstances.hard[1].gameOver and
                                           gameInstances.hard[2].gameOver and
                                           gameInstances.hard[3].gameOver
                end

                if allGridsFinished then
                    if allWon then
                        -- Play win sound
                        local winSound = assetManager.getSound("win")
                        if winSound then
                            love.audio.play(winSound)
                        end
                        showMessage("Parabéns! Você acertou todos os grids!", "green", 3)
                    else
                        local wonCount = 0
                        for _, result in ipairs(results) do
                            if result.won then wonCount = wonCount + 1 end
                        end

                        if wonCount > 0 then
                            -- Play win sound for partial wins too
                            local winSound = assetManager.getSound("win")
                            if winSound then
                                love.audio.play(winSound)
                            end
                            showMessage("Você acertou " .. wonCount .. " de " .. #results ..
                                            " grids!", "yellow", 3)
                        else
                            local allAnswersText = ""
                            for i, answer in ipairs(allAnswers) do
                                if i > 1 then
                                    allAnswersText = allAnswersText .. ", "
                                end
                                allAnswersText = allAnswersText .. answer:upper()
                            end
                            showMessage("Perdeu! Palavras: " .. allAnswersText, "red", 5)
                        end
                    end
                elseif allWon then
                    -- Play win sound when all grids are won before reaching max attempts
                    local winSound = assetManager.getSound("win")
                    if winSound then
                        love.audio.play(winSound)
                    end
                    showMessage("Parabéns! Você acertou todos os grids!", "green", 3)
                end
            else
                -- Play invalid guess sound
                local invalidSound = assetManager.getSound("invalid_guess")
                if invalidSound then
                    love.audio.play(invalidSound)
                end
                
                local errorMessage = "Digite uma palavra de 5 letras"
                for _, result in pairs(results) do
                    if result and result.message then
                        errorMessage = result.message
                        break
                    end
                end
                showMessage(errorMessage, "red", 2)
            end
        else
            -- Play invalid guess sound for incomplete words
            local invalidSound = assetManager.getSound("invalid_guess")
            if invalidSound then
                love.audio.play(invalidSound)
            end
            showMessage("Digite uma palavra de 5 letras", "yellow", 2)
        end
    elseif key:match("^%a$") and #currentInput < 5 then
        -- Play click sound for letter keys
        local clickSound = assetManager.getSound("click")
        if clickSound then
            love.audio.play(clickSound)
        end
        
        currentInput = currentInput .. key:upper()
        currentCol = currentCol + 1
    end

    return currentInput, currentRow, currentCol
end

-- Atualiza estado do teclado virtual baseado em todas as tentativas
function gameLogic.updateKeyboardStateMultiGrid(gameState, gameInstances, keyboardState)
    for k in pairs(keyboardState) do keyboardState[k] = nil end

    local grids = {}
    if gameState == "game" then
        grids = {gameInstances.easy}
    elseif gameState == "game_medium" then
        grids = gameInstances.medium
    elseif gameState == "game_hard" then
        grids = gameInstances.hard
    end

    if #grids > 1 then
        for gridIndex, gameInstance in ipairs(grids) do
            if gameInstance then
                local gameStateData = gameInstance:getGameState()

                for _, attempt in ipairs(gameStateData.attempts) do
                    for i = 1, #attempt.word do
                        local letter = attempt.word:sub(i, i):upper()
                        local result = attempt.result.letters[i]

                        if not keyboardState[letter] then
                            keyboardState[letter] = {}
                        end

                        if result == true then
                            keyboardState[letter][gridIndex] = "correct"
                        elseif result == false and keyboardState[letter][gridIndex] ~= "correct" then
                            keyboardState[letter][gridIndex] = "wrong_position"
                        elseif result == nil and keyboardState[letter][gridIndex] ~= "correct" and
                            keyboardState[letter][gridIndex] ~= "wrong_position" then
                            keyboardState[letter][gridIndex] = "not_in_word"
                        end
                    end
                end
            end
        end
    else
        for _, gameInstance in ipairs(grids) do
            if gameInstance then
                local gameStateData = gameInstance:getGameState()

                for _, attempt in ipairs(gameStateData.attempts) do
                    for i = 1, #attempt.word do
                        local letter = attempt.word:sub(i, i):upper()
                        local result = attempt.result.letters[i]

                        if result == true then
                            keyboardState[letter] = "correct"
                        elseif result == false and keyboardState[letter] ~= "correct" then
                            keyboardState[letter] = "wrong_position"
                        elseif result == nil and keyboardState[letter] ~= "correct" and
                            keyboardState[letter] ~= "wrong_position" then
                            keyboardState[letter] = "not_in_word"
                        end
                    end
                end
            end
        end
    end
end

return gameLogic
