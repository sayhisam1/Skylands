local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Maid = require("Maid")
local YieldingEffect = require("YieldingEffect")

local InputYieldingEffect = setmetatable({}, YieldingEffect)

InputYieldingEffect.__index = InputYieldingEffect
InputYieldingEffect.TotalTime = 0
InputYieldingEffect.Preemptive = true

local MAX_YIELD_TIME = 3 -- waits atmost 10 seconds before automatically passing yield

function InputYieldingEffect:New(owner, network_channel, input_name, desired_press_state, total_time)
    self.__index = self
    local obj = setmetatable(YieldingEffect:New(total_time), self)
    obj._networkChannel = network_channel
    obj._inputName = input_name
    obj._desiredPressState = desired_press_state or false
    obj._owner = owner
    obj._maid = Maid.new()
    return obj
end

-- waits for yield event to occur
function InputYieldingEffect:Wait()
    local completed = false

    local task
    if IsServer then
        task =
            self._networkChannel:Subscribe(
            self._inputName,
            function(plr, pressed_down, time_pressed)
                if plr == self._owner:GetReference() and pressed_down == self._desiredPressState then
                    completed = true
                end
            end
        )
    elseif IsClient then
        task =
            self._networkChannel:Subscribe(
            self._inputName,
            function(pressed_down)
                if pressed_down == self._desiredPressState then
                    completed = true
                end
            end
        )
    end
    self._maid:GiveTask(task)

    local start_t = tick()
    while (tick() - start_t < MAX_YIELD_TIME and self._running and completed == false) do
        wait()
    end

    return completed or (tick() - start_t >= MAX_YIELD_TIME)
end

function InputYieldingEffect:Start()
    self._running = true
    local res = self:Wait()
    self:Yield()
    if res == false then
        self:Stop()
        return
    end
    for _, effect in pairs(self._yieldedEffects) do
        effect:Start()
    end
end

function InputYieldingEffect:Stop()
    self._running = false
    self._maid:Destroy()
    for _, effect in pairs(self._yieldedEffects) do
        effect:Stop()
    end
end

return InputYieldingEffect
