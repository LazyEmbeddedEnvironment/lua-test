#!/usr/bin/lua
-- Internal
local config = require("Config")
local appBase = require("AppBase")

local _Input = require('pl.class')() -- Private
local Input = require('pl.class')() -- Public

-- Private class
function _Input:_init()
    self.zmq = require("lzmq")
    self.zpoller = require("lzmq.poller")
    self.context = self.zmq.context()
    self.subscribers = {}
end
function _Input:createSubscriber(name, callback)
    print ("subscribing to " .. name)
    local subscriber, err = self.context:socket(self.zmq.SUB, {
        subscribe = name;
        connect   = "tcp://localhost:"..appBase.zmqPort;
    })
    self.zmq.assert(subscriber, err)
    table.insert(self.subscribers, {name=name, subscriber=subscriber})
    
    self:generatePoller()
    self.poller:add(subscriber, self.zmq.POLLIN, function() 
        callback(subscriber:recv())
    end)
    self.poller:start()
end
function _Input:generatePoller()
    self:destroyPoller()
    self.poller = self.zpoller.new(#self.subscribers)
end
function _Input:destroyPoller()
    self.poller = self.poller and self.poller:stop() -- stop returns nil, hopefully garbage collected
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



return Input("bool.Input.instanceName.test", function(message) 
    print ("Received message")
    print (message)
end)




