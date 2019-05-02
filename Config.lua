#!/usr/bin/lua
local pretty = require("pl.pretty")
local appBase = require("AppBase")
local rapidjson = require("rapidjson")
local home = os.getenv ( "HOME" )
local configRecipe = home.."/"..appBase.frameWorkName.."/config/"..appBase.appName
local configFilePath = configRecipe.."."..appBase.name..".json"
local config = nil
local function openConfigFile() return io.open(configFilePath, "r") end
local function generateConfig()
    local defaultConfig = rapidjson.load(configRecipe..".json")
    rapidjson.dump(defaultConfig, configFilePath)
    return openConfigFile()
end
local function tryOpenConfig()
    local file = openConfigFile()
    local forceReadFile = file and file or generateConfig()
    config = rapidjson.decode(forceReadFile:read("*all"))
    forceReadFile:close()
end

tryOpenConfig()

pretty.dump(config)