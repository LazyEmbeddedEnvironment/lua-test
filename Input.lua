#!/usr/bin/lua
-- Internal
local config = require("Config")
local appBase = require("AppBase")

local _Input = require('pl.class')() -- Private
local Input = require('pl.class')() -- Public

-- Private class
function _Input:_init()
    self.zmq = require("lzmq")
    self.poller = require("wrappers.Poller")
    self.context = self.zmq.context()
end
function _Input:createSubscriber(name, callback)
    print ("subscribing to " .. name)
    local subscriber, err = self.context:socket(self.zmq.SUB, {
        subscribe = name;
        connect   = "tcp://localhost:"..appBase.zmqPort;
    })
    self.zmq.assert(subscriber, err)

    self.poller:addSubscriber(subscriber, callback)
end

local private = _Input() -- hopefully singleton

function Input:_init(name, callback)
    assert(type(name) == "string", "Input has to be created with a name")
    if callback then assert(type(callback) == "function", "Input has to be created with a name") end
    self.name = name
    self.connection = config[".subscribtions"][self.name]
    if not self.connection then print("Input "..self.name.." is disconnected") return end
    private:createSubscriber(self.connection, callback)
end

config.insert("myKey.mofo.notsomuch.to.you", {because="i Cant"})
print("nei")

return Input("bool.Input.instanceName.test", function(message) 
    print (message)
end)




