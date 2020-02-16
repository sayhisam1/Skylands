-- Time
-- sayhisam1

--[=[

	Implementation of NTP for server/client time synchronization

--]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local Queue = require("Queue")

-- Bigger queue means less variance in latency, but also less recent data
local MAX_QUEUE_SIZE = 15

-- This is the remoteevent used in the timesynchro (todo: remove dependence on this)
local Remote = game.ReplicatedStorage.Remote:WaitForChild("SyncTime")
local Time = {
    offset = 0,
    LastSync = 0,
    IsMaster = false,
    k = 0,
    queue = nil,
    M_prev = nil,
    M_curr = nil,
    S_prev = nil,
    S_curr = nil,
    min_off = 101000,
    latency = 0,
    k = 0
}
Time.__index = Time

function Time:New(IsMaster)
    local obj = {}
    obj.IsMaster = IsMaster
    obj.offset = 0
    setmetatable(obj, self)
    local conn
    if (obj.IsMaster) then
        --		print("CREATING NEW TIME MASTER")
        conn =
            Remote.OnServerEvent:Connect(
            function(player, t1)
                local t2 = tick()

                Remote:FireClient(player, t1, t2, tick())
            end
        )
    else
        obj.queue = Queue:New()
        conn =
            Remote.OnClientEvent:Connect(
            function(t1, t2, t3)
                local t4 = tick()
                local offset = 0.5 * (t2 - t1 + t3 - t4)
                local avg_delay = 0.5 * (t4 - t1 - t3 + t2)
                obj:PushQueue(offset, avg_delay)
                --print("CLIENT LOCAL TIME offset SET TO ",obj.offset)
            end
        )
    end

    obj.conn = conn
    return obj
end

function Time:GetTime()
    return self.offset + tick()
end
function Time:GetLatency()
    return self.latency
end
function Time:PushQueue(offset, avg_delay)
    if (self.queue:GetSize() >= MAX_QUEUE_SIZE) then
        local t = self.queue:Dequeue()
        if self.min_off == t[2] then
            self.min_off = 1000000
        end
    end
    self.queue:Enqueue({offset, avg_delay})
    local calculatedDelay = 0
    for i = 1, self.queue:GetSize(), 1 do
        local t = self.queue:Dequeue()
        if (self.min_off > t[2]) then
            self.min_off = t[2]
            self.offset = t[1]
        end
        calculatedDelay = calculatedDelay + t[2]
        self.queue:Enqueue(t)
    end
    self.latency = calculatedDelay / (self.queue:GetSize()) -- update average latency
end

function Time:Sync()
    if (self.IsMaster) then
        return --We don't need to do anything on server..
    end
    Remote:FireServer(tick())
end

return Time
