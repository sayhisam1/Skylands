--[[
	AttackPhaseObject class
	Defines an attack (eg: Left Punch)

--]]
--REQUIRED CLASSES--
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Event = require(ReplicatedStorage.Objects.Shared.Event)
local State = require(ReplicatedStorage.Objects.Shared.FSM.State)

local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)
local AnimationEffect = require(ReplicatedStorage.Objects.Combat.Effects.Yielding.AnimationEffect)

local AttackPhaseObject = setmetatable({}, State)
AttackPhaseObject.__index = AttackPhaseObject
AttackPhaseObject.ClassName = script.Name

--CONSTRUCTOR--

function AttackPhaseObject.new(phase_name)
    assert(type(phase_name) == "string", "Invald phase name " .. phase_name)
    phase_name = string.upper(phase_name)
    local self = setmetatable(State.new(phase_name), AttackPhaseObject)

    self.Completed = Event.new()
    self._maid:GiveTask(self.Completed)
    self.TotalTime = 0
    self.StartTime = math.huge
    -- incase phase has no animation --
    self._maid:GiveTask(self.Loaded:Connect(
        function()
            self.StartTime = _G.Clock:GetTime()
            coroutine.wrap(
                function()
                    wait(self.TotalTime)
                    if self.__loaded then
                        self.Completed:Fire()
                    end
                end
            )()
        end
    ))
    self._maid:GiveTask(self.Completed:Connect(
        function()
            self.TotalTime = _G.Clock:GetTime() - self.StartTime -- Now that we finished the phase, we can note down how much time the phase actually took
        end
    ))
    return self
end

-- Adds an abstract effect to the attack phase - must be start/stoppable
function AttackPhaseObject:WithEffect(effect)
    -- Handle yielding effects
    self:Log(1, "AttackPhase add effect",effect.ClassName)
    self._maid:GiveTask(effect)
    if type(effect.Yielded) == "table" then
        if effect.Preemptive then
            self._maid:GiveTask(effect.Yielded:Connect(
                function()
                    self:Preempt()
                end
            ))
        end
        self.TotalTime = math.max(effect:GetTotalTime(), self.TotalTime)
    end

    -- Handle effect starting
    self._maid:GiveTask(self.Loaded:Connect(
        function()
            effect:Start()
        end
    ))
    self._maid:GiveTask(self.Unloaded:Connect(
        function()
            effect:Stop()
        end
    ))
end

function AttackPhaseObject:WithEffectFunction(func)
    assert(type(func) == "function", "Tried to set invalid effect function")
    self:Log(1, "AttackPhase add effect function")
    local new_effect = Effect.new()
    new_effect:SetFunction(func)
    return self:WithEffect(new_effect)
end

function AttackPhaseObject:GetTotalTime()
    return self.TotalTime
end

function AttackPhaseObject:WithAnimation(char, animation, preemptive)
    self:Log(1, "AttackPhase add animation",animation)
    preemptive = preemptive or true
    local effect = AnimationEffect.new(char, animation)
    effect:SetPreemptive(preemptive)
    return self:WithEffect(effect)
end


function AttackPhaseObject:Preempt()
    if self.Completed then
        self.Completed:Fire()
    end
end

return AttackPhaseObject
