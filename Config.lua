local Config = require("pl.class")() -- Private
require("pl.stringx").import() -- Inserts penlight functions to standard string table
-- Config API
local userMethods = {"insert", "overwrite"}
function Config:appendUserMethodsToConfig()
    self.config.insert = self:insert()
    self.config.overwrite = self:overwrite()
end
-- Something that you should not care of
function Config:_init() 
    local home = os.getenv("HOME")
    self.rapidjson = require("rapidjson")
    local appBase = require("AppBase")
    self.configRecipe = home.."/"..appBase.frameWorkName.."/config/"..appBase.appName
    self.configFilePath = self.configRecipe.."."..appBase.name..".json"
end
function Config:openConfigFile(path) return io.open(path, "r") end
function Config:exampleConfig() return {} end
function Config:tryGetDefaultConfig()
    local defaultConfPath = self.configRecipe..".json"
    local file = self:openConfigFile(defaultConfPath)
    if not file then self.rapidjson.dump(self:exampleConfig(), defaultConfPath,{pretty=true}) end
    return self.rapidjson.load(defaultConfPath) 
end
function Config:generateConfig()
    local defaultConfig = self:tryGetDefaultConfig()
    self.rapidjson.dump(defaultConfig, self.configFilePath,{pretty=true})
    return self:openConfigFile(self.configFilePath)
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
function Config:openConfig()
    local file = self:openConfigFile(self.configFilePath)
    local forceReadFile = file and file or self:generateConfig()
    self.config = self.rapidjson.decode(forceReadFile:read("*all"))
    forceReadFile:close()
    self:checkForChangedDefaultConfFile()
    self:rewriteConfigFile()
    return self.config
end
function Config:rewriteConfigFile( )
    for _, funcName in ipairs(userMethods) do
        self.config = table.removeKey(self.config, funcName)
    end
    self.rapidjson.dump(self.config, self.configFilePath,{pretty=true})
    self:appendUserMethodsToConfig() 
end

local pretty = require("pl.pretty")
function Config:checkKeyValue(key, value)
    assert(type(key) == "string", "Key has to be a string value, when key is of type "..type(key))
    assert(type(value) ~= "nil", "Inserted value can not be of type nil")
end
-- key division is "|" which means the key="subs.boat.first|haven.gate|entry" will create the following
-- { "subs":{:"boat":{"first":{ "haven.gate":{ "entry":"YOURValue" } } } } }
function Config:extractKeyToObjectStructure(key) 
    local divisions = key:split('|')
    local createObj = true
    local keys = {}
    for _, subKey in ipairs(divisions) do
        if (createObj) then
            local subSubKeys = subKey:split('.')
            for _, subSubKey in ipairs(subSubKeys) do
                table.insert(keys, subSubKey)
            end
        else
            table.insert(keys, subKey)
        end
        createObj = not createObj
    end
    return keys
end 
function Config:getConfigIterator(inputKey, subKeys)
    local tableIterator = self.config
    for i,key in ipairs(subKeys) do
        if (i == #subKeys) then break end
        if (type(tableIterator[key]) == "table") then
            tableIterator = tableIterator[key]
        elseif (type(tableIterator[key]) == "nil") then
            tableIterator[key] = {}
            tableIterator = tableIterator[key]
        else
            return false, "Error indexing config table with key " .. inputKey
        end
    end
    print("\n\n\n")
    pretty.dump(self.config)
    return tableIterator
end
function Config:insert() return function(key, value)
    self:checkKeyValue(key, value)
    local subKeys = self:extractKeyToObjectStructure(key)
    local tabIterator, err = self:getConfigIterator(key, subKeys)
    if tabIterator == false then return false, err end
    if (type(tabIterator[subKeys[#subKeys]]) == "nil") then
        tabIterator[subKeys[#subKeys]] = value
    end
    self:rewriteConfigFile()
    return true
end end
function Config:overwrite() return function(key, value)
    self:checkKeyValue(key, value)
    local subKeys = self:extractKeyToObjectStructure(key)
    local tabIterator, err = self:getConfigIterator(key, subKeys)
    if tabIterator == false then return false, err end
    tabIterator[subKeys[#subKeys]] = value
    self:rewriteConfigFile()
    return true
end end

function table.removeKey(t, k) -- https://swfoo.com/2014/07/11/lua-table-remove-by-key/
	local i = 0
	local keys, values = {},{}
	for k,v in pairs(t) do
		i = i + 1
		keys[i] = k
		values[i] = v
	end
	while i>0 do
		if keys[i] == k then
			table.remove(keys, i)
			table.remove(values, i)
			break
		end
		i = i - 1
	end
	local a = {}
	for i = 1,#keys do a[keys[i]] = values[i] end
	return a
end

local private = Config()
return private:openConfig()
