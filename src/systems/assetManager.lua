local assetManager = {}

local assets = {images = {}, sounds = {}, fonts = {}}

local paths = {
    images = "assets/images/",
    sounds = "assets/audio/",
    fonts = "assets/fonts/",
    data = "assets/data/"
}

-- Carrega uma imagem
function assetManager.loadImage(name, filename)
    if filename then
        assets.images[name] = love.graphics.newImage(filename)
    else
        assets.images[name] = love.graphics.newImage(paths.images .. name)
    end
    return assets.images[name]
end

-- Carrega um som
function assetManager.loadSound(name, filename, soundType)
    soundType = soundType or "static"
    if filename then
        assets.sounds[name] = love.audio.newSource(filename, soundType)
    else
        assets.sounds[name] = love.audio.newSource(paths.sounds .. name, soundType)
    end
    return assets.sounds[name]
end

-- Carrega uma fonte
function assetManager.loadFont(name, filename, size)
    if filename and size then
        assets.fonts[name] = love.graphics.newFont(filename, size)
    elseif size then
        assets.fonts[name] = love.graphics.newFont(size)
    else
        assets.fonts[name] = love.graphics.newFont(paths.fonts .. name)
    end
    return assets.fonts[name]
end

-- Obtém assets carregados
function assetManager.getImage(name) return assets.images[name] end

function assetManager.getSound(name) return assets.sounds[name] end

function assetManager.getFont(name) return assets.fonts[name] end

-- Retorna caminho de arquivo de dados
function assetManager.getDataPath(filename) return paths.data .. filename end

-- Retorna caminhos dos dados do jogo
function assetManager.getGameDataPaths()
    return {
        answers = paths.data .. "valid_answers.csv",
        guesses = paths.data .. "valid_guesses.csv"
    }
end

-- Carrega todos os assets do jogo
function assetManager.loadAll()
    assetManager.loadImage("background", "assets/images/fundo.jpg")
    assetManager.loadSound("click", "assets/audio/click_sound.mp3", "static")
    assets.fonts.base = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 12)
end

-- Limpa todos os assets
function assetManager.clear()
    assets.images = {}
    assets.sounds = {}
    assets.fonts = {}
end

return assetManager
