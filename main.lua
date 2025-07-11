-- Menu berr.io com tela de instruções
local menu = {}

-- Estados da tela
local gameState = "menu"  -- "menu" ou "instructions"

-- Tempo acumulado para o efeito bouncing
local bounceTime = 0 

-- Configurações da tela
local screenWidth, screenHeight = 900, 700

-- Imagem de fundo
local backgroundImage

-- Fontes
local titleFont = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 60)
local buttonFont = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 25)
local textFont = love.graphics.newFont('/assets/PressStart2P-Regular.ttf', 15)

-- Cores (tema dark como GitHub)
local colors = {
    background = {0.08, 0.08, 0.08},  -- Fundo escuro
    title = {1, 1, 1},                -- Texto branco
    button = {0.15, 0.15, 0.15},      -- Botão cinza escuro
    buttonHover = {0.25, 0.25, 0.25}, -- Botão hover cinza claro
    buttonText = {1, 1, 1},           -- Texto botão branco
    border = {0.35, 0.35, 0.35},      -- Borda cinza
    green = {0.4, 0.8, 0.4},          -- Verde para exemplo
    yellow = {0.9, 0.8, 0.2},         -- Amarelo para exemplo
    red = {0.8, 0.3, 0.3},            -- Vermelho para exemplo
    text = {0.9, 0.9, 0.9}            -- Texto das instruções
}

-- Botões do menu principal
local menuButtons = {
    {
        text = "Jogar",
        x = 300, y = 380,
        width = 300,
        height = 80,
        action = function()
            print("Iniciando jogo...")
            -- Aqui você iniciaria o jogo
        end
    },
    {
        text = "Como Jogar",
        x = 300, y = 500,
        width = 300,
        height = 80,
        action = function()
            gameState = "instructions"
        end
    }
}

function love.load()
    love.window.setMode(screenWidth, screenHeight)
    love.window.setTitle("berr.io")

    -- Carregar imagem de fundo
    backgroundImage = love.graphics.newImage("assets/fundo.jpg")

    -- Carregar som de clique
    clickSound = love.audio.newSource("assets/click_sound.mp3", "static")
    
    -- -- Centralizar botões do menu
    -- for i, button in ipairs(menuButtons) do
    --     button.x = (screenWidth - button.width) / 2
    --     button.y = 300 + (i - 1) * 80
    -- end
end

function love.update(dt)
    local mouseX, mouseY = love.mouse.getPosition()

    bounceTime = bounceTime + dt
    
    if gameState == "menu" then
        -- Verificar hover nos botões do menu
        for i, button in ipairs(menuButtons) do
            button.isHovered = isPointInRect(mouseX, mouseY, button.x, button.y, button.width, button.height)
        end
    end
end 

function love.draw()
    -- Desenhar imagem de fundo
    love.graphics.setColor(1, 1, 1)  -- Cor branca (sem filtro de cor)
    love.graphics.draw(backgroundImage, 0, 0, 0, screenWidth / backgroundImage:getWidth(), screenHeight / backgroundImage:getHeight())
    
    -- Overlay escuro semi-transparente para melhor legibilidade do texto
    love.graphics.setColor(0, 0, 0, 0.6)  -- Preto com 60% de transparência
    love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
    if gameState == "menu" then
        drawMenu()
    elseif gameState == "instructions" then
        drawInstructions()
    end
end

function drawMenu()
    -- Descrição de direitos autorais no cabeçalho
    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    local copyright =
        "Trabalho final da disciplina de LP, feito em LOVE2D. ®"
    local textWidth = textFont:getWidth(copyright)
    love.graphics.print(copyright, (screenWidth - textWidth) / 2, 670)
    -- Título "berr.io" com efeito bouncing + rotação
    love.graphics.setFont(titleFont)
    local titleText = "berr.io"
    local titleWidth = titleFont:getWidth(titleText)
    local titleHeight = titleFont:getHeight()

    -- Efeito de escala (bouncing) e rotação
    local scale = 1 + 0.05 * math.sin(bounceTime * 3)         -- Bouncing
    local angle = math.rad(2) * math.sin(bounceTime * 2)      -- Rotação oscilante (2 graus)

    -- Posição centralizada considerando o centro rotacionado e escalado
    local centerX = screenWidth / 2
    local centerY = 180 + titleHeight / 2

    love.graphics.setColor(colors.title)
    love.graphics.push()
    love.graphics.translate(centerX, centerY)     -- Move o ponto de origem para o centro do título
    love.graphics.rotate(angle)                   -- Aplica rotação suave
    love.graphics.scale(scale, scale)             -- Aplica a escala (pulsação)
    love.graphics.translate(-titleWidth / 2, -titleHeight / 2) -- Corrige posição
    love.graphics.print(titleText, 0, 0)
    love.graphics.pop()

    -- Desenhar botões do menu
    love.graphics.setFont(buttonFont)
    for i, button in ipairs(menuButtons) do
        -- Cor do botão
        if button.isHovered then
            love.graphics.setColor(colors.buttonHover)
        else
            love.graphics.setColor(colors.button)
        end
        
        -- Retângulo do botão
        love.graphics.rectangle("fill", button.x, button.y, button.width, button.height, 8, 8)
        
        -- Borda do botão
        love.graphics.setColor(colors.border)
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height, 8, 8)
        
        -- Texto do botão centralizado
        love.graphics.setColor(colors.buttonText)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight()
        local textX = button.x + (button.width - textWidth) / 2
        local textY = button.y + (button.height - textHeight) / 2
        love.graphics.print(button.text, textX, textY)
    end
end

function drawInstructions()
    -- Título das instruções
    love.graphics.setColor(colors.title)
    love.graphics.setFont(titleFont)
    local titleText = "Como Jogar"
    local titleWidth = titleFont:getWidth(titleText)
    love.graphics.print(titleText, (screenWidth - titleWidth) / 2, 50)
    
    -- Texto das instruções
    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    
    local instructions = {
        "   • Você terá 6 tentativas. Cada uma delas deve ser uma",
        "   palavra que exista.",
        "",
        "   • Acentos e cedilha são ignorados.",
        "",
        "   • Após chutar, as letras mudarão para indicar o quão",
        "   perto você está da resposta:",
        "",
        "   - Se a letra for VERDE, ela está presente na palavra",
        "   e na posição correta.",
        "",
        "   - Se a letra for AMARELA, ela está presente na palavra,",
        "   mas na posição errada.",
        "",
        "   - Se a letra for VERMELHA, ela NÃO está na palavra."
    }
    
    local startY = 140
    local lineHeight = 26
    
    for i, line in ipairs(instructions) do
        local y = startY + (i - 1) * lineHeight
        
        -- Colorir as linhas de exemplo
        if string.find(line, "VERDE") then
            love.graphics.setColor(colors.green)
        elseif string.find(line, "AMARELA") then
            love.graphics.setColor(colors.yellow)
        elseif string.find(line, "VERMELHA") then
            love.graphics.setColor(colors.red)
        else
            love.graphics.setColor(colors.text)
        end
        
        love.graphics.print(line, 15, y)
    end

    -- Exemplos visuais
    love.graphics.setColor(colors.text)
    love.graphics.setFont(textFont)
    love.graphics.print("Exemplos:", 400, 570)
    
    -- Quadrados coloridos de exemplo
    local exampleY = 600
    local squareSize = 18
    
    -- Verde
    love.graphics.setColor(colors.green)
    love.graphics.rectangle("fill", 320, exampleY, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição correta", 370, exampleY + 2)
    
    -- Amarelo  
    love.graphics.setColor(colors.yellow)
    love.graphics.rectangle("fill", 320, exampleY + 25, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Posição errada", 370, exampleY + 27)
    
    -- Vermelho
    love.graphics.setColor(colors.red)
    love.graphics.rectangle("fill", 320, exampleY + 50, squareSize, squareSize)
    love.graphics.setColor(colors.text)
    love.graphics.print("Não está na palavra", 350, exampleY + 52)
end

function love.mousepressed(x, y, button)
    if button == 1 then -- Botão esquerdo
        if gameState == "menu" then
            for i, btn in ipairs(menuButtons) do
                if isPointInRect(x, y, btn.x, btn.y, btn.width, btn.height) then
                    love.audio.play(clickSound)  -- TOCA O SOM
                    btn.action()                 -- Executa a ação do botão
                    break
                end
            end
        end
    end
end

function love.keypressed(key)
    if key == "escape" then
        if gameState == "instructions" then
            gameState = "menu"
        else
            love.event.quit()
        end
    end
end

-- Função auxiliar para verificar clique
function isPointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end