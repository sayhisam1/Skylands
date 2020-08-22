--[[
	AttackObject class
	Defines an attack (eg: Left Punch)
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Clock = require(ReplicatedStorage.Clock)
local Event = require(ReplicatedStorage.Objects.Shared.Event)
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local FSM = require(ReplicatedStorage.Objects.Shared.FSM.EventDrivenFSM)
local State = require(ReplicatedStorage.Objects.Shared.FSM.State)
local EventTransition = require(ReplicatedStorage.Objects.Shared.FSM.EventTransition)

local AttackObject = setmetatable({}, BaseObject)
AttackObject.ClassName = script.Name
AttackObject.__index = AttackObject
--CONSTRUCTOR--
-- @param attack_name -- A string name to assign to the attack (should be unique across all attacks)
function AttackObject.new(attack_name)
    assert(type(attack_name) == "string", "Attack must have a valid name! (given: " .. attack_name .. ", of type: " .. type(attack_name) .. ")")
    local self = setmetatable(BaseObject.new(attack_name), AttackObject)

    self.Name = attack_name
    self.Running = false

    self.PhaseChanged = Event.new()
    self.Started = Event.new()
    self.Stopped = Event.new()
    self._FSM = FSM.new()
    self._CurrentPhase = nil
    self._phases = {}
    self.StartTime = math.huge
    self._maid:GiveTask(self._FSM)
    self._maid:GiveTask(self.Stopped)
    self._maid:GiveTask(self.Started)
    self._maid:GiveTask(self.PhaseChanged)
    local basestate = State.new("BASE_ATTACK_STATE", nil, nil, true) -- internal base state for FSM (normally idle case)
    self._baseState = basestate
    self._maid:GiveTask(basestate)
    self._FSM:AddState(basestate)

    self._maid:GiveTask(
        function()
            self:Stop()
        end
    )
    return self
end

function AttackObject:AddPhase(phase, next_phase)
    assert(type(phase) == "table", "Phase not an object!")
    assert(self._phases[phase.Name] == nil, string.format("Phase with name %s already exists!", phase.Name))

    local next_phase_name = "BASE_ATTACK_STATE"
    if type(next_phase) == "table" then
        next_phase_name = next_phase.Name
    elseif type(next_phase) == "string" then
        next_phase_name = next_phase
    end
    self._phases[phase.Name] = phase
    -- Register transitions
    if next_phase_name then
        local transition = EventTransition.new(phase.Completed, nil, next_phase_name)
        phase:AddTransition(transition)
    end
    self._maid:GiveTask(phase)
    self._FSM:AddState(phase)
end

function AttackObject:GetPhase(phase_name)
    phase_name = string.upper(phase_name)
    for _, phase in pairs(self._phases) do
        if phase.Name == phase_name then
            return phase
        end
    end
end

function AttackObject:AddLinearPhasePathway(phases)
    local start_phase = phases[1]
    -- Setup transition from base state to first state
    local BaseStateHook = EventTransition.new(self.Started, nil, start_phase.Name)
    self._baseState:AddTransition(BaseStateHook)
    for key, phase in pairs(phases) do
        local next_phase = phases[key + 1]
        local next_phase_name = (next_phase and next_phase.Name) or nil
        self:AddPhase(phase, next_phase_name)
    end
end

-- Starts an attack
function AttackObject:Start()
    if self.Running then
        return
    end
    self.Running = true
    self:Log(1, "Start attack", self.Name)
    self._maid:GiveTask(
        self._phases["END"].Unloaded:Connect(
            function()
                self:Stop()
            end
        )
    )
    self.StartTime = Clock:GetTime()
    self._FSM:Start()
    self.Started:Fire()
end

function AttackObject:Stop()
    if not self.Running then
        return
    end
    self.Running = false
    self._FSM:Stop()
    self.Stopped:Fire()
end

function AttackObject:GetTotalTime()
    local t = 0
    for _, phase in pairs(self._phases) do
        t = t + phase:GetTotalTime()
    end
    return t
end

return AttackObject
