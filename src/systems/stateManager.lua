local stateManager = {}

local validStates = {"menu", "instructions", "difficulty", "game", "game_medium", "game_hard"}
local currentState = "menu"
local stateCallbacks = {}

-- Define estado atual do jogo
function stateManager.setState(newState)
    local isValid = false
    for _, state in ipairs(validStates) do
        if state == newState then
            isValid = true
            break
        end
    end

    if not isValid then
        print("Warning: Invalid state '" .. newState .. "'")
        return false
    end

    local oldState = currentState
    currentState = newState

    if stateCallbacks[newState] then stateCallbacks[newState](oldState, newState) end

    return true
end

-- Retorna estado atual
function stateManager.getState() return currentState end

-- Registra callback para mudança de estado
function stateManager.onEnterState(state, callback) stateCallbacks[state] = callback end

-- Verifica se está em modo de jogo
function stateManager.isGameState()
    return currentState == "game" or currentState == "game_medium" or currentState == "game_hard"
end

-- Retorna estado anterior para voltar
function stateManager.getBackState()
    local backStates = {
        instructions = "menu",
        difficulty = "menu",
        game = "menu",
        game_medium = "menu",
        game_hard = "menu"
    }

    return backStates[currentState] or nil
end

return stateManager
