#!/usr/bin/lua
local config = require("Config")
local appBase = require("AppBase")

local _Output = require('pl.class')() -- Private
local Output = require('pl.class')() -- Public

-- Private class
function _Output:_init()
    self.zmq = require("lzmq")
    self.poller = require("wrappers.Poller")
    self.context = self.zmq.context()
    local publisher, err = self.context:socket{self.zmq.PUB, bind = "tcp://*:"..appBase.zmqPort}
    self.zmq.assert(publisher, err)
    self.publisher = publisher
end
function _Output:send(name, val)
    self.publisher:sendx(name, tostring(val))
end

local private = _Output()

function Output:_init(name)
    assert(type(name) == "string", "Output has to be created with a name")
    self.name = name
end

function Output:send(val)
    private:send(self.name, val == nil and "nil" or val)
end

local out = Output("bool.Output.instanceName.testingPub")
local out2 = Output("string.Output.instanceName.test2")

local zloop = require("lzmq.loop")

local loop = zloop.new(1, ctx)

loop:add_interval(1000, function()
    out:send(true)        
end)

loop:start()

-- THIS DOES NOT WORK
loop:add_interval(1000, function()
    out:send(true)        
end)
  


