local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Maid = require("Maid")
local YieldingEffect = require("YieldingEffect")

local LookvectorYieldingEffect = setmetatable({}, YieldingEffect)

LookvectorYieldingEffect.__index = LookvectorYieldingEffect
LookvectorYieldingEffect.TotalTime = 0
LookvectorYieldingEffect.Preemptive = true

local MAX_YIELD_TIME = 3 -- waits atmost this many seconds before automatically passing yield

function LookvectorYieldingEffect:New(owner, network_channel, time)
    self.__index = self
    local obj = setmetatable(YieldingEffect:New(time), self)
    obj._networkChannel = network_channel
    obj._networkChannelName = "LookVectorSync"
    obj.TotalTime = MAX_YIELD_TIME
    obj._owner = owner
    obj._maid = Maid.new()
    return obj
end

-- waits for yield event to occur
function LookvectorYieldingEffect:Wait()
    local completed = false
    local result = nil
    local task
    if IsServer then
        task =
            self._networkChannel:Subscribe(
            self._networkChannelName,
            function(plr, ray, time_pressed)
                if plr == self._owner:GetReference() and typeof(ray) == "Ray" then
                    completed = true
                    result = ray
                end
            end,
            .1
        )
    elseif IsClient then
        -- if we are client, then we broadcast the lookvector to the networkchannel
        local time_pressed = _G.Clock:GetTime()
        local ray = _G.Services.LocalPlayer:GetLookvectorFromCharacter()
        task = self._networkChannel:Publish(self._networkChannelName, ray, time_pressed)
        completed = true
        result = ray
    end
    if task then
        self._maid:GiveTask(task)
    end
    local start_t = tick()
    while (tick() - start_t < MAX_YIELD_TIME and self._running and completed == false) do
        wait()
    end

    return (completed or (tick() - start_t >= MAX_YIELD_TIME)), result
end

function LookvectorYieldingEffect:Start()
    self._running = true
    local completed, result = self:Wait()
    self:Yield()
    if completed == false then
        self:Stop()
        return
    end
    for _, effect in pairs(self._yieldedEffects) do
        effect:Start(result)
    end
end

function LookvectorYieldingEffect:Stop()
    self._running = false
    self._maid:Destroy()
    for _, effect in pairs(self._yieldedEffects) do
        effect:Stop()
    end
end

return LookvectorYieldingEffect
