local Loop = require('pl.class')() 

function Loop:_init(allocation)
    self.zmq = require("lzmq")
    self.zloop = require("lzmq.loop")
    self.ctx = self.zmq.context()
    self.subscribers = {}
end
function Loop:addSubscriber(subscriber, callback)
    table.insert(self.subscribers, {subscriber=subscriber, callback=callback})

    self.loop:add_socket(subscriber, self.zmq.POLLIN, function() 
        callback(subscriber:recv())
    end)
    -- self.loop:start()
end
function Loop:generatePoller(allocation)
    self.loop = self.zloop.new(allocation, self.ctx)
end
function Loop:start() self.loop:start() end
function Loop:addInterval(time, cb) self.loop:add_interval(time, cb) end


return Loop()
