local lapp = require 'pl.lapp'
local args = lapp [[
Common arguments
	-n,--name (default instanceName)  Application instance name
]]
local function getAppName()
	local app = require("pl.app")
	local path = app.appfile("")
	local findAppName = path:match("%/%.(%a+)%/") -- What if the script is in a hidden folder .someFolderName
	return findAppName
end 
local AppBase = { 
	appName = getAppName(),
	name = args.name,
	frameWorkName = "friend",
	zmqPort = "5578"
}

return AppBase

