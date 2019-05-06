local Poller = require('pl.class')() -- Private

function Poller:_init()
    self.zmq = require("lzmq")
    self.zpoller = require("lzmq.poller")
    self.subscribers = {}
    self:generatePoller()
end
function Poller:addSubscriber(subscriber, callback)
    table.insert(self.subscribers, {name=name, subscriber=subscriber})

    self:generatePoller()
    self.poller:add(subscriber, self.zmq.POLLIN, function() 
        callback(subscriber:recv())
    end)
    self.poller:start()
end
function Poller:generatePoller()
    self:destroyPoller()
    self.poller = self.zpoller.new(#self.subscribers)
end
function Poller:destroyPoller()
    self.poller = self.poller and self.poller:stop() -- stop returns nil, hopefully garbage collected
end

return Poller()
