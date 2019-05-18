#!/usr/bin/lua
-- Internal
local config = require("Config")
local appBase = require("AppBase")

local InputCollector = require('pl.class')() -- Private
local InputCreator = require('pl.class')() -- Public

-- Private class
function InputCollector:_init()
    self.zmq = require("lzmq")
    self.poller = require("wrappers.Loop")
    self.context = self.zmq.context()
    config.insert("|.subscribtions||.config|maxInputs", 128)
    local maxInputs = config[".subscribtions"][".config"]["maxInputs"]
    self.poller:generatePoller(maxInputs)
end
function InputCollector:createSubscriber(name, callback)
    print ("subscribing to " .. name)
    local subscriber, err = self.context:socket(self.zmq.SUB, {
        subscribe = name;
        connect   = "tcp://localhost:"..appBase.zmqPort;
    })
    self.zmq.assert(subscriber, err)

    self.poller:addSubscriber(subscriber, callback)
end

local inputCollection = InputCollector() -- hopefully singleton

function InputCreator:_init(name, callback)
    assert(type(name) == "string", "Input has to be created with a name")
    if callback then assert(type(callback) == "function", "Input has to be created with a name") end
    self.name = name
    config.insert("|.subscribtions||"..name, "disconnected")
    self.connection = config[".subscribtions"][self.name]
    if not self.connection then print("Input "..self.name.." is disconnected") return end
    inputCollection:createSubscriber(self.connection, callback)
end

return InputCreator


