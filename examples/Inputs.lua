local loop = require("wrappers.Loop")
local input = require("Input")

local x = input("bool.Input.instanceName.test", function(message) 
    print (message)
end)

local y = input("bool.Input.instanceName.test.gate.1", function(message) 
    print (message)
end)

loop:start()