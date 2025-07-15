-- Configuration and Constants
local config = {}

-- Cores
config.colors = {
    background = {0.08, 0.08, 0.08},
    title = {1, 1, 1},
    button = {0.15, 0.15, 0.15},
    buttonHover = {0.25, 0.25, 0.25},
    buttonText = {1, 1, 1},
    border = {0.35, 0.35, 0.35},
    green = {0.4, 0.8, 0.4},
    yellow = {0.9, 0.8, 0.2},
    red = {0.8, 0.3, 0.3},
    text = {0.9, 0.9, 0.9}
}

-- Teclado virtual
config.keyboardLayout = {
    {"Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"},
    {"A", "S", "D", "F", "G", "H", "J", "K", "L"},
    {"←", "Z", "X", "C", "V", "B", "N", "M", "ENTER"}
}

-- Função para criar botões do menu principal
function config.createMenuButtons()
    return {
        {
            text = "Jogar",
            relativeY = 0.475, -- porcentagem da altura da tela
            action = function(changeState) changeState("difficulty") end
        }, {
            text = "Como Jogar",
            relativeY = 0.625, -- porcentagem da altura da tela
            action = function(changeState) changeState("instructions") end
        }
    }
end

-- Função para criar botões da tela de dificuldade
function config.createDifficultyButtons(initGame)
    return {
        {
            text = "Fácil",
            relativeY = 0.3125,
            action = function(changeState)
                initGame("easy")
                changeState("game")
            end
        }, {
            text = "Médio",
            relativeY = 0.5,
            action = function(changeState)
                initGame("medium")
                changeState("game_medium")
            end
        }, {
            text = "Difícil",
            relativeY = 0.6875,
            action = function(changeState)
                initGame("hard")
                changeState("game_hard")
            end
        }
    }
end

-- Estados que permitem voltar
config.backStates = {
    instructions = true,
    difficulty = true,
    game = true,
    game_medium = true,
    game_hard = true
}

return config
