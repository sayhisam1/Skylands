local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)
local Effect = require("Effect")

local YieldingEffect = setmetatable({}, Effect)

YieldingEffect.__index = YieldingEffect
YieldingEffect.TotalTime = 0
YieldingEffect.Preemptive = false

function YieldingEffect:New(time)
    self.__index = self
    local obj = setmetatable(Effect:New(), self)
    obj.Yielded = Event:New()
    obj._yieldedEffects = {}
    obj.TotalTime = time or 0
    return obj
end

function YieldingEffect:GetTotalTime()
    return self.TotalTime
end

function YieldingEffect:BindYieldedEffect(effect)
    self._yieldedEffects[#self._yieldedEffects + 1] = effect
end

-- waits for yield event to occur
function YieldingEffect:Wait()
    warn("Wait yielding effect not implemented!")
end

function YieldingEffect:Start()
    self:Wait()
    for _, effect in pairs(self._yieldedEffects) do
        effect:Start()
    end
end

function YieldingEffect:Stop()
    for _, effect in pairs(self._yieldedEffects) do
        effect:Stop()
    end
end

function YieldingEffect:SetPreemptive(is_preemptive)
    self.Preemptive = is_preemptive
end

function YieldingEffect:Yield()
    self.Yielded:Fire()
end
return YieldingEffect
