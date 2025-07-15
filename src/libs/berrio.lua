Berrio = {}
Berrio.__index = Berrio

-- Cria nova instância do jogo
function Berrio:new(answersFile, validGuessesFile)
    local self = setmetatable({}, Berrio)

    self.maxAttempts = 6
    self.wordLength = 5

    self.answers = {}
    self.validGuesses = {}

    self.currentAnswer = ""
    self.attempts = {}
    self.gameOver = false
    self.won = false

    self:loadWords(answersFile, validGuessesFile)
    self:selectRandomAnswer()

    return self
end

-- Carrega palavras dos arquivos CSV
function Berrio:loadWords(answersFile, validGuessesFile)
    self.answers = self:loadCSVToSet(answersFile)
    self.validGuesses = self:loadCSVToSet(validGuessesFile)

    for word in pairs(self.answers) do self.validGuesses[word] = true end
end

-- Carrega palavras de arquivo CSV para uma tabela
function Berrio:loadCSVToSet(filename)
    local wordSet = {}
    local file = io.open(filename, "r")

    if not file then error("Não foi possível abrir o arquivo: " .. filename) end

    local _ = file:read("*line")

    for line in file:lines() do
        local word = line:match("^%s*(.-)%s*$")
        if word and #word == self.wordLength then wordSet[word:lower()] = true end
    end

    file:close()
    return wordSet
end

-- Seleciona palavra aleatória para resposta
function Berrio:selectRandomAnswer()
    local answers = {}
    for word in pairs(self.answers) do table.insert(answers, word) end

    if #answers > 0 then
        self.currentAnswer = answers[math.random(#answers)]
    else
        error("Nenhuma palavra válida encontrada para sorteio")
    end
end

-- Verifica se palavra é válida
function Berrio:isvalidGuess(word) return self.validGuesses[word:lower()] ~= nil end

-- Compara tentativa com resposta correta
function Berrio:checkMatch(guess)
    guess = guess:lower()
    local answer = self.currentAnswer
    local result = {}

    local letterCount = {}
    for i = 1, #answer do
        local letter = answer:sub(i, i)
        letterCount[letter] = (letterCount[letter] or 0) + 1
    end

    for i = 1, #guess do
        local guessLetter = guess:sub(i, i)
        local answerLetter = answer:sub(i, i)

        if guessLetter == answerLetter then
            result[i] = true
            letterCount[guessLetter] = letterCount[guessLetter] - 1
        else
            result[i] = nil
        end
    end

    for i = 1, #guess do
        if result[i] == nil then
            local guessLetter = guess:sub(i, i)

            if letterCount[guessLetter] and letterCount[guessLetter] > 0 then
                result[i] = false
                letterCount[guessLetter] = letterCount[guessLetter] - 1
            else
                result[i] = nil
            end
        end
    end

    local perfectMatch = true
    for i = 1, 5 do
        if result[i] ~= true then
            perfectMatch = false
            break
        end
    end

    return {perfect = perfectMatch, letters = result}
end

-- Faz uma tentativa de adivinhação
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

    local match = self:checkMatch(word)

    table.insert(self.attempts, {word = word, result = match})

    if match.perfect then
        self.gameOver = true
        self.won = true
    elseif #self.attempts >= self.maxAttempts then
        self.gameOver = true
        self.won = false
    end

    return {success = true, match = match, gameOver = self.gameOver, won = self.won}
end

-- Retorna estado atual do jogo
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

-- Reinicia jogo
function Berrio:reset()
    self.attempts = {}
    self.gameOver = false
    self.won = false
    self:selectRandomAnswer()
end

return Berrio
