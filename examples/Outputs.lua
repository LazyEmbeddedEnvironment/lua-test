local loop = require("wrappers.Loop")
local output = require("Output")

local x = output("bool.actuator.1")

local y = output("bool.actuator.2")

local toggle = true

loop:addInterval(1000, function()
    x:send(toggle)
    toggle = not toggle        
    y:send(toggle)        
end)

loop:start()
