-- Test script to verify the modular structure works
local config = require("config")
local utils = require("utils")
local ui = require("ui")
local gameLogic = require("gameLogic")
local gameDraw = require("gameDraw")

print("All modules loaded successfully!")
print("Config colors:", config.colors ~= nil)
print("Utils functions:", utils.getScale ~= nil)
print("UI functions:", ui.drawMenu ~= nil)
print("GameLogic functions:", gameLogic.initGame ~= nil)
print("GameDraw functions:", gameDraw.drawGameEasy ~= nil)
