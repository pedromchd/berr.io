-- Game Logic Functions
local gameLogic = {}

-- Import asset manager for data paths
local assetManager = require("src.systems.assetManager")

-- Função para inicializar o jogo
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

-- Função para processar entrada de tecla
function gameLogic.processKeyInput(key, currentInput, currentRow, currentCol, showingMessage,
                                   gameState, gameInstances, keyboardState, debugInfo, showMessage,
                                   updateKeyboardStateMultiGrid)
    if showingMessage then return currentInput, currentRow, currentCol end

    -- Verificar se algum jogo ainda está ativo
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
            currentInput = currentInput:sub(1, -2)
            currentCol = math.max(1, currentCol - 1)
        end
    elseif key == "return" or key == "enter" or key == "ENTER" then
        if #currentInput == 5 then
            local results = {}
            local anyGameOver = false

            -- Fazer o mesmo palpite em todas as grids ATIVAS (que ainda não terminaram)
            if gameState == "game" then
                -- Modo fácil: apenas um grid
                if not gameInstances.easy.gameOver then
                    local result = gameInstances.easy:makeGuess(currentInput)
                    results[1] = result
                    anyGameOver = result.gameOver and not result.won
                end
            elseif gameState == "game_medium" then
                -- Modo médio: 2 grids simultâneos
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
                -- Modo difícil: 3 grids simultâneos
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

            -- Verificar se todas as grids foram ganhas (incluindo as já terminadas)
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

            -- Capturar informações de debug detalhadas (todas as grids)
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

            -- Verificar se pelo menos uma grid processou a jogada
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

                -- Atualizar estado do teclado (agora considerando todas as grids)
                updateKeyboardStateMultiGrid()

                -- Verificar se todas as grids terminaram (won ou lost)
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
                        showMessage("Parabéns! Você acertou todos os grids!", "green", 3)
                    else
                        -- Mostrar quantos acertou
                        local wonCount = 0
                        for _, result in ipairs(results) do
                            if result.won then wonCount = wonCount + 1 end
                        end

                        if wonCount > 0 then
                            showMessage("Você acertou " .. wonCount .. " de " .. #results ..
                                            " grids!", "yellow", 3)
                        else
                            -- Mostrar todas as palavras corretas
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
                    -- Caso especial: ganhou todas mas nem todas terminaram (isso não deveria acontecer, mas por segurança)
                    showMessage("Parabéns! Você acertou todos os grids!", "green", 3)
                end
            else
                -- Mostrar mensagem de erro usando o primeiro resultado válido
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
            showMessage("Digite uma palavra de 5 letras", "yellow", 2)
        end
    elseif key:match("^%a$") and #currentInput < 5 then
        currentInput = currentInput .. key:upper()
        currentCol = currentCol + 1
    end

    return currentInput, currentRow, currentCol
end

-- Função para atualizar estado do teclado (considerando todas as grids nos modos multi-grid)
function gameLogic.updateKeyboardStateMultiGrid(gameState, gameInstances, keyboardState)
    -- Resetar estado
    for k in pairs(keyboardState) do keyboardState[k] = nil end

    local grids = {}
    if gameState == "game" then
        grids = {gameInstances.easy}
    elseif gameState == "game_medium" then
        grids = gameInstances.medium
    elseif gameState == "game_hard" then
        grids = gameInstances.hard
    end

    -- Processar todas as grids
    for _, gameInstance in ipairs(grids) do
        if gameInstance then
            local gameState = gameInstance:getGameState()

            for _, attempt in ipairs(gameState.attempts) do
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

return gameLogic
