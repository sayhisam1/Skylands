--[[
	AttackPhaseObject class
	Defines an attack (eg: Left Punch)
	
--]]
--REQUIRED CLASSES--
local DEBUGMODE = false
local function printd(...)
    if DEBUGMODE then print(...) end
end
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)
local State = require("State")


local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local ANIMATIONS = ASSETS:WaitForChild("Animations")
local Effect = require("Effect")
local AnimationEffect = require("AnimationEffect")

local AttackPhaseObject = setmetatable({}, State)
AttackPhaseObject.__index = AttackPhaseObject
--CONSTRUCTOR--

function AttackPhaseObject:New(owner, phase_name, total_time)
    assert(
        type(owner) == "table" and (type(owner:GetReference()) == "userdata" or owner.IsBot),
        "Attacks need an owner!"
    )
    assert(type(phase_name) == "string", "Invald phase name "..phase_name)
    phase_name = string.upper(phase_name)
    self.__index = self
    local obj = setmetatable(State:New(phase_name), self)

    obj.Completed = Event:New()
    obj.TotalTime = total_time or 0
    obj.MaximumPossibleTime = total_time
    obj.StartTime = math.huge
    obj._owner = owner
    -- incase phase has no animation --
    obj.Loaded:Connect(
        function()
            obj.StartTime = _G.Clock:GetTime()
            printd("LOADED", obj.Name)
            coroutine.wrap(
                function()
                    wait(obj.TotalTime)
                    if obj.__loaded then
                        obj.Completed:Fire()
                    end
                end
            )()
        end
    )
    obj.Completed:Connect(
        function()
            obj.TotalTime = _G.Clock:GetTime() - obj.StartTime -- Now that we finished the phase, we can note down how much time the phase actually took
            obj._Shared.LastPhaseCompletePower = math.clamp((_G.Clock:GetTime() - obj.StartTime) / obj.TotalTime, 0, 1)
        end
    )
    obj.Unloaded:Connect(
        function()
            printd("UNLOADED", obj.Name)
        end
    )
    return obj
end

function AttackPhaseObject:Destroy()
    self.Completed:Destroy()
    State.Destroy(self)
end

-- Adds an abstract effect to the attack phase - must be start/stoppable
function AttackPhaseObject:WithEffect(effect)
    -- Handle yielding effects
    if type(effect.Yielded) == 'table' then
        if effect.Preemptive then
            effect.Yielded:Connect(
                function()
                    self:Preempt()
                end
            )
        end
        self.TotalTime = math.max(effect:GetTotalTime(), self.TotalTime)
    end

    -- Handle effect starting
    self.Loaded:Connect(
        function()
            effect:Start(self)
        end
    )
    self.Unloaded:Connect(
        function()
            effect:Stop(self)
        end
    )
end

function AttackPhaseObject:WithEffectFunction(func)
    assert(type(func) == 'function', "Tried to set invalid effect function")
    local new_effect = Effect:New(self._owner)
    new_effect:SetFunction(func)
    self:WithEffect(new_effect)
end

function AttackPhaseObject:GetTotalTime()
    return self.TotalTime
end

function AttackPhaseObject:WithAnimation(animation_name, preemptive)
    preemptive = preemptive or true
    assert(type(animation_name) == 'string' or type(animation_name) == 'userdata',"Tried to add invalid animation with "..tostring(animation_name))
    local animation = animation_name
    if type(animation) == 'string' then
        animation = ANIMATIONS:FindFirstChild(animation_name, true)
        assert(animation, "Tried to add invalid animation "..animation_name)
    end
    local effect = AnimationEffect:New(self._owner, animation)
    effect:SetPreemptive(preemptive)
    self.AnimationEffect = effect
    return self:WithEffect(effect)
end

function AttackPhaseObject:Destroy()
    self._owner = nil
    State.Destroy(self)
end

function AttackPhaseObject:Preempt()
    if self.Completed then
        self.Completed:Fire()
    end
end
return AttackPhaseObject
