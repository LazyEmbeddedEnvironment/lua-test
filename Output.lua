#!/usr/bin/lua
local config = require("Config")
local appBase = require("AppBase")
require("Input") -- This initiates polling mechanism

local OutputPublisher = require('pl.class')() -- Private
local OutputCreator = require('pl.class')() -- Public

-- Private class
function OutputPublisher:_init()
    self.zmq = require("lzmq")
    self.context = self.zmq.context()
    local publisher, err = self.context:socket{self.zmq.PUB, bind = "tcp://*:"..appBase.zmqPort}
    self.zmq.assert(publisher, err)
    self.publisher = publisher
end
function OutputPublisher:send(name, val)
    self.publisher:sendx(name, tostring(val))
end

local publisher = OutputPublisher()

function OutputCreator:_init(name)
    assert(type(name) == "string", "Output has to be created with a name")
    self.name = name
end

function OutputCreator:send(val)
    publisher:send(self.name, val == nil and "nil" or val)
end

return OutputCreator


  


