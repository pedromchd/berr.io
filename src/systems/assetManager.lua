-- Asset Manager
local assetManager = {}

-- Asset storage
local assets = {images = {}, sounds = {}, fonts = {}}

-- Asset paths
local paths = {
    images = "assets/images/",
    sounds = "assets/audio/",
    fonts = "assets/fonts/",
    data = "assets/data/"
}

-- Load an image asset
function assetManager.loadImage(name, filename)
    if filename then
        assets.images[name] = love.graphics.newImage(filename)
    else
        assets.images[name] = love.graphics.newImage(paths.images .. name)
    end
    return assets.images[name]
end

-- Load a sound asset
function assetManager.loadSound(name, filename, soundType)
    soundType = soundType or "static"
    if filename then
        assets.sounds[name] = love.audio.newSource(filename, soundType)
    else
        assets.sounds[name] = love.audio.newSource(paths.sounds .. name, soundType)
    end
    return assets.sounds[name]
end

-- Load a font asset
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

-- Get an asset
function assetManager.getImage(name) return assets.images[name] end

function assetManager.getSound(name) return assets.sounds[name] end

function assetManager.getFont(name) return assets.fonts[name] end

-- Load all game assets
function assetManager.loadAll()
    -- Load background image
    assetManager.loadImage("background", "assets/images/fundo.jpg")

    -- Load click sound
    assetManager.loadSound("click", "assets/audio/click_sound.mp3", "static")

    -- Load base font - sizes will be calculated dynamically in utils
    assets.fonts.base = love.graphics.newFont("assets/fonts/PressStart2P-Regular.ttf", 12)
end

-- Clear all assets
function assetManager.clear()
    assets.images = {}
    assets.sounds = {}
    assets.fonts = {}
end

return assetManager
