local DEBUGMODE = true
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local fastSpawn = require("fastSpawn")

local Event = {
    BoundEvents = {}
}

Event.__index = Event

--=CONSTRUCTOR=--

function Event:New()
    self.__index = self
    local obj = setmetatable({}, Event)
    obj.BoundEvents = {}
    for i, v in pairs(self.BoundEvents) do
        obj.BoundEvents[i] = v
    end
    return obj
end

function Event:Destroy()
    for i, v in pairs(self.BoundEvents) do
        self.BoundEvents[i] = nil
    end
    self.BoundEvents = {}
end
function Event:Connect(func)
    local loc = tostring(func)
    self.BoundEvents[loc] = func
    local disconnector = {}

    local EventObj = self
    function disconnector.Disconnect()
        EventObj.BoundEvents[loc] = nil
    end
    function disconnector.Destroy()
        disconnector:Disconnect()
    end
    return disconnector
end

function Event:Fire(...)
    if DEBUGMODE then
        for i, v in pairs(self.BoundEvents) do
            fastSpawn(v, ...)
            -- spawn(
            --     function()
            --         v(unpack(args))
            --     end
            -- )
        end
    else
        for i, v in pairs(self.BoundEvents) do
            coroutine.wrap(v)(...)
        end
    end
end

function Event:DisconnectAll()
    for i, v in pairs(self.BoundEvents) do
        self.BoundEvents[i] = nil
    end
end

return Event
