#!/usr/bin/lua
local pretty = require("pl.pretty")
local appBase = require("AppBase")
local rapidjson = require("rapidjson")
local home = os.getenv ( "HOME" )
local configRecipe = home.."/"..appBase.frameWorkName.."/config/"..appBase.appName
local configFilePath = configRecipe.."."..appBase.name..".json"

local Config = require('pl.class')() -- Private
function Config:openConfigFile(path) return io.open(path, "r") end
function Config:exampleConfig() return {} end
function Config:tryGetDefaultConfig()
    local defaultConfPath = configRecipe..".json"
    local file = self:openConfigFile(defaultConfPath)
    if not file then rapidjson.dump(exampleConfig(), defaultConfPath) end
    return rapidjson.load(defaultConfPath) 
end
function Config:generateConfig()
    local defaultConfig = self:tryGetDefaultConfig()
    rapidjson.dump(defaultConfig, configFilePath)
    return self:openConfigFile(configFilePath)
end
function Config:insertNewKeysIfKnown(finalConfigTab, defConfigTab)
    local ty1 = type(finalConfigTab)
    local ty2 = type(defConfigTab)
    if ty1 ~= ty2 then return false end
    if ty1 ~= 'table' and ty2 ~= 'table' then return true end

    for k1,v1 in pairs(finalConfigTab) do
        local v2 = defConfigTab[k1]
        if v2 == nil or not self:insertNewKeysIfKnown(v1,v2) then return false end
    end
    for k2,v2 in pairs(defConfigTab) do
        local v1 = finalConfigTab[k2]
        if v1 == nil then finalConfigTab[k2] = v2 end
        if v1 == nil or not self:insertNewKeysIfKnown(v1,v2) then return false end
    end
    return true
end
function Config:checkForChangedDefaultConfFile()
    local defaultConfig = self:tryGetDefaultConfig()
    self:insertNewKeysIfKnown(config, defaultConfig)
end
function Config:tryOpenConfig()
    local file = self:openConfigFile(configFilePath)
    local forceReadFile = file and file or self:generateConfig()
    self.config = rapidjson.decode(forceReadFile:read("*all"))
    forceReadFile:close()
    self:checkForChangedDefaultConfFile()
    rapidjson.dump(self.config, configFilePath) 
    return self.config
end

local private = Config()
return private:tryOpenConfig()
