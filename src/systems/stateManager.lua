-- Simple Game State Manager
local stateManager = {}

-- Valid states and their transitions
local validStates = {"menu", "instructions", "difficulty", "game", "game_medium", "game_hard"}

-- Current state
local currentState = "menu"

-- State change callbacks
local stateCallbacks = {}

-- Set current state
function stateManager.setState(newState)
    -- Validate state
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

    -- Call state change callback if it exists
    if stateCallbacks[newState] then stateCallbacks[newState](oldState, newState) end

    return true
end

-- Get current state
function stateManager.getState() return currentState end

-- Register a callback for when entering a specific state
function stateManager.onEnterState(state, callback) stateCallbacks[state] = callback end

-- Check if current state is one of the game states
function stateManager.isGameState()
    return currentState == "game" or currentState == "game_medium" or currentState == "game_hard"
end

-- Get back state (where to go when pressing ESC)
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
