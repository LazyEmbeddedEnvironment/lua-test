#!/usr/bin/lua
local pretty = require("pl.pretty")
local appBase = require("AppBase")
local rapidjson = require("rapidjson")
local home = os.getenv ( "HOME" )
local configRecipe = home.."/"..appBase.frameWorkName.."/config/"..appBase.appName
local configFilePath = configRecipe.."."..appBase.name..".json"
local config = nil
local function openConfigFile() return io.open(configFilePath, "r") end
local function getDefaultConfig() return rapidjson.load(configRecipe..".json") end
local function generateConfig()
    local defaultConfig = getDefaultConfig()
    rapidjson.dump(defaultConfig, configFilePath)
    return openConfigFile()
end
local function insertNewKeysIfKnown(finalConfigTab, defConfigTab)
    local ty1 = type(finalConfigTab)
    local ty2 = type(defConfigTab)
    if ty1 ~= ty2 then return false end
    if ty1 ~= 'table' and ty2 ~= 'table' then return true end

    for k1,v1 in pairs(finalConfigTab) do
        local v2 = defConfigTab[k1]
        if v2 == nil or not insertNewKeysIfKnown(v1,v2) then return false end
    end
    for k2,v2 in pairs(defConfigTab) do
        local v1 = finalConfigTab[k2]
        if v1 == nil then finalConfigTab[k2] = v2 end
        if v1 == nil or not insertNewKeysIfKnown(v1,v2) then return false end
    end
    return true
end
local function checkForChangedDefaultConfFile()
    local defaultConfig = getDefaultConfig()
    insertNewKeysIfKnown(config, defaultConfig)
end
local function tryOpenConfig()
    local file = openConfigFile()
    local forceReadFile = file and file or generateConfig()
    config = rapidjson.decode(forceReadFile:read("*all"))
    forceReadFile:close()
    checkForChangedDefaultConfFile()
    rapidjson.dump(config, configFilePath) 
end



tryOpenConfig()
