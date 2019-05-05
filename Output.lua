#!/usr/bin/lua
local config = require("Config")
local appBase = require("AppBase")

local _Output = require('pl.class')() -- Private
local Output = require('pl.class')() -- Public

-- Private class
function _Output:_init()
    self.zmq = require("lzmq")
    self.zpoller = require("lzmq.poller")
    self.context = self.zmq.context()
    local publisher, err = self.context:socket{self.zmq.PUB, bind = "tcp://*:"..appBase.zmqPort}
    self.zmq.assert(publisher, err)
    self.publisher = publisher
end
function _Output:send(name, val)
    self.publisher:sendx(name, tostring(val))
end

local private = _Output() -- hopefully singleton

function Output:_init(name)
    assert(type(name) == "string", "Output has to be created with a name")
    self.name = name
end

function Output:send(val)
    private:send(self.name, val == nil and "nil" or val)
end

local out = Output("bool.Output.instanceName.testingPub")
Output("bool.Output.instanceName.testingPub"):send(true)
Output("bool.Output.instanceName.testingPub"):send(true)
Output("bool.Output.instanceName.testingPub"):send(true)
Output("bool.Output.instanceName.testingPub"):send(true)
Output("bool.Output.instanceName.testingPub"):send(true)
Output("bool.Output.instanceName.testingPub"):send(true)

local ztimer  = require "lzmq.timer"
function sleep(sec)
    ztimer.sleep(sec * 1000)
end

while true do
    out:send(true)        
    sleep (1);
end
  


