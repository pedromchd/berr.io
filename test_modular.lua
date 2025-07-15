-- Simple test to verify modules load correctly
print("Testing module loading...")

-- Test loading all modules
local success, err = pcall(function()
    local config = require("src.modules.config")
    print("✓ config.lua loaded")

    local utils = require("src.modules.utils")
    print("✓ utils.lua loaded")

    local ui = require("src.modules.ui")
    print("✓ ui.lua loaded")

    local gameLogic = require("src.modules.gameLogic")
    print("✓ gameLogic.lua loaded")

    local gameDraw = require("src.modules.gameDraw")
    print("✓ gameDraw.lua loaded")

    local assetManager = require("src.systems.assetManager")
    print("✓ assetManager.lua loaded")

    local stateManager = require("src.systems.stateManager")
    print("✓ stateManager.lua loaded")

    -- Test basic functionality
    local state = stateManager.getState()
    print("✓ Current state: " .. state)

    local result = stateManager.setState("instructions")
    print("✓ State change successful: " .. tostring(result))

    local backState = stateManager.getBackState()
    print("✓ Back state: " .. (backState or "none"))
end)

if success then
    print("\n✅ All modules loaded successfully!")
    print("✅ Basic functionality working!")
else
    print("\n❌ Error loading modules:")
    print(err)
end
