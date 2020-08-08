local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local YieldingEffect = require(ReplicatedStorage.Objects.Combat.Abstract.YieldingEffect)

local ChannelYieldingEffect = setmetatable({}, YieldingEffect)

ChannelYieldingEffect.__index = ChannelYieldingEffect
ChannelYieldingEffect.ClassName = script.Name
ChannelYieldingEffect.TotalTime = 3
ChannelYieldingEffect.Preemptive = true

local MAX_YIELD_TIME = 3 -- waits atmost MAX_YIELD_TIME seconds before automatically failing yield

function ChannelYieldingEffect.new(channel, topic, cache_lookup_time, callback)
    local self = setmetatable(YieldingEffect.new(callback), ChannelYieldingEffect)
    self._channel = channel
    self._topic = topic
    self._cacheLookupTime = cache_lookup_time
    return self
end

-- waits for yield event to occur
function ChannelYieldingEffect:Wait()
    local completed = false
    local task =
        self._channel:Subscribe(
        self._topic,
        function(...)
            completed = {...}
        end,
        self._cacheLookupTime
    )
    self._maid:GiveTask(task)

    local start_t = tick()
    while (tick() - start_t < MAX_YIELD_TIME and self._running and completed == false) do
        wait()
    end

    return completed or ((tick() - start_t < MAX_YIELD_TIME) and self._running)
end

return ChannelYieldingEffect
