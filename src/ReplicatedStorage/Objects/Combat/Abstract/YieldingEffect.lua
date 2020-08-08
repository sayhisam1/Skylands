local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = require(ReplicatedStorage.Objects.Shared.Event)
local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)

local YieldingEffect = setmetatable({}, Effect)

YieldingEffect.__index = YieldingEffect
YieldingEffect.ClassName = script.Name
YieldingEffect.Preemptive = false
YieldingEffect.TotalTime = 0

function YieldingEffect.new(callback, fail_callback)
    callback = callback or function()
        end
    local self = setmetatable(Effect.new(), YieldingEffect)
    self:SetFunction(callback)
    self._failFunc = fail_callback or function()
        end
    self.Yielded = Event.new()
    self._yieldedEffects = {}
    return self
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
    self._running = true
    local args = self:Wait()
    if not args then
        coroutine.wrap(self._failFunc)(self)
    else
        coroutine.wrap(self._func)(self, unpack(args))
        for _, effect in pairs(self._yieldedEffects) do
            effect:Start()
        end
    end
end

function YieldingEffect:SetPreemptive(is_preemptive)
    self.Preemptive = is_preemptive
end

function YieldingEffect:Yield()
    self.Yielded:Fire()
end

return YieldingEffect
