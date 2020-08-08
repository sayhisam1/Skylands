local ReplicatedStorage = game:GetService("ReplicatedStorage")

local fastSpawn = require(ReplicatedStorage.Utils.fastSpawn)

local Event = {
    _boundEvents = {}
}

Event.__index = Event
Event.ClassName = script.Name
--=CONSTRUCTOR=--

function Event.new()
    local self = setmetatable({}, Event)
    self._boundEvents = {}
    for i, v in pairs(self._boundEvents) do
        self._boundEvents[i] = v
    end
    return self
end

function Event:Destroy()
    self:DisconnectAll()
end
function Event:Connect(func)
    self._boundEvents[func] = func

    local disconnector = {}
    function disconnector.Disconnect()
        self._boundEvents[func] = nil
    end
    function disconnector.Destroy()
        disconnector:Disconnect()
    end
    return disconnector
end

function Event:Fire(...)
    for i, v in pairs(self._boundEvents) do
        fastSpawn(v, ...)
    end
end

function Event:DisconnectAll()
    for i, v in pairs(self._boundEvents) do
        self._boundEvents[i] = nil
    end
end

return Event
