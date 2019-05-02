#!/usr/bin/lua
local appBase = require("AppBase")
local rapidjson = require("rapidjson")
local home = os.getenv ( "HOME" )
local configRecipe = home.."/"..appBase.frameWorkName.."/config/"..appBase.appName
local configFilePath = configRecipe.."."..appBase.name..".json"
local config = nil
local function generateConfig()
    local defaultConfig = rapidjson.load(configRecipe..".json")
    
    local success, err = rapidjson.dump(defaultConfig, configFilePath)
end
local function tryOpenConfig()
    local file = io.open(configFilePath, "r")
    if file == nil then generateConfig() return
    else file:close() end
    config = rapidjson.load(configFilePath)
end


tryOpenConfig()

print(config)