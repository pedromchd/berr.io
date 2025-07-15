Berrio = {}
Berrio.__index = Berrio

function Berrio:new(answersFile, validGuessesFile)
    local self = setmetatable({}, Berrio)

    -- Configurações
    self.maxAttempts = 6
    self.wordLength = 5

    -- Dados carregados
    self.answers = {} -- Set de palavras que podem ser sorteadas
    self.validGuesses = {} -- Set de todas as palavras válidas

    -- Estado do jogo
    self.currentAnswer = ""
    self.attempts = {} -- Histórico de tentativas
    self.gameOver = false
    self.won = false

    -- Carregar dados
    self:loadWords(answersFile, validGuessesFile)
    self:selectRandomAnswer()

    return self
end

function Berrio:loadWords(answersFile, validGuessesFile)
    -- Carrega respostas válidas
    self.answers = self:loadCSVToSet(answersFile)

    -- Carrega tentativas válidas
    self.validGuesses = self:loadCSVToSet(validGuessesFile)

    -- Adiciona answers às valid words
    for word in pairs(self.answers) do self.validGuesses[word] = true end
end

function Berrio:loadCSVToSet(filename)
    local wordSet = {}
    local file = io.open(filename, "r")

    if not file then error("Não foi possível abrir o arquivo: " .. filename) end

    -- Pula cabeçalho
    local _ = file:read("*line")

    -- Lê palavras
    for line in file:lines() do
        local word = line:match("^%s*(.-)%s*$") -- Remove espaços
        if word and #word == self.wordLength then wordSet[word:lower()] = true end
    end

    file:close()
    return wordSet
end

function Berrio:selectRandomAnswer()
    local answers = {}
    for word in pairs(self.answers) do table.insert(answers, word) end

    if #answers > 0 then
        self.currentAnswer = answers[math.random(#answers)]
    else
        error("Nenhuma palavra válida encontrada para sorteio")
    end
end

function Berrio:isvalidGuess(word) return self.validGuesses[word:lower()] ~= nil end

function Berrio:checkMatch(guess)
    guess = guess:lower()
    local answer = self.currentAnswer
    local result = {}

    -- Contador de letras disponíveis na resposta
    local letterCount = {}
    for i = 1, #answer do
        local letter = answer:sub(i, i)
        letterCount[letter] = (letterCount[letter] or 0) + 1
    end

    -- Primeira passada: marcar posições exatas
    for i = 1, #guess do
        local guessLetter = guess:sub(i, i)
        local answerLetter = answer:sub(i, i)

        if guessLetter == answerLetter then
            result[i] = true -- Posição correta
            letterCount[guessLetter] = letterCount[guessLetter] - 1
        else
            result[i] = nil -- Placeholder
        end
    end

    -- Segunda passada: marcar posições parciais
    for i = 1, #guess do
        if result[i] == nil then -- Não foi marcada como exata
            local guessLetter = guess:sub(i, i)

            if letterCount[guessLetter] and letterCount[guessLetter] > 0 then
                result[i] = false -- Letra certa, posição errada
                letterCount[guessLetter] = letterCount[guessLetter] - 1
            else
                result[i] = nil -- Letra não existe ou já foi usada
            end
        end
    end

    -- Verifica se é match perfeito
    local perfectMatch = true
    for i = 1, #result do
        if result[i] ~= true then
            perfectMatch = false
            break
        end
    end

    return {perfect = perfectMatch, letters = result}
end

function Berrio:makeGuess(word)
    if self.gameOver then return {success = false, message = "Jogo já terminou"} end

    if #self.attempts >= self.maxAttempts then
        return {success = false, message = "Máximo de tentativas atingido"}
    end

    word = word:lower()

    if #word ~= self.wordLength then
        return {success = false, message = "Palavra deve ter 5 letras"}
    end

    if not self:isvalidGuess(word) then
        return {success = false, message = "Palavra não está na lista"}
    end

    -- Verifica match
    local match = self:checkMatch(word)

    -- Adiciona ao histórico
    table.insert(self.attempts, {word = word, result = match})

    -- Verifica fim de jogo
    if match.perfect then
        self.gameOver = true
        self.won = true
    elseif #self.attempts >= self.maxAttempts then
        self.gameOver = true
        self.won = false
    end

    return {success = true, match = match, gameOver = self.gameOver, won = self.won}
end

function Berrio:getGameState()
    return {
        attempts = self.attempts,
        currentAttempt = #self.attempts + 1,
        maxAttempts = self.maxAttempts,
        gameOver = self.gameOver,
        won = self.won,
        answer = self.gameOver and self.currentAnswer or nil
    }
end

function Berrio:reset()
    self.attempts = {}
    self.gameOver = false
    self.won = false
    self:selectRandomAnswer()
end

return Berrio
