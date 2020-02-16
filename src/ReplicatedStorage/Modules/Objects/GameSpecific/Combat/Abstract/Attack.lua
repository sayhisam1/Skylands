--[[
	AttackObject class
	Defines an attack (eg: Left Punch)
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Pickler = require("Pickler")
local AttackShared = require("AttackShared")
local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)

local FSM = require("EventDrivenFSM")
local State = require("State")
local EventTransition = require("EventTransition")
local Maid = require("Maid")

local AttackObject = {}

AttackObject.__index = AttackObject
--CONSTRUCTOR--
-- @param attack_name -- A string name to assign to the attack (should be unique across all attacks)
-- @param owner --  A PlayerObject specifying the owner (a.k.a creator) of attack. An attack CANNOT exist without one!
--                  If an environmental object must make an attack, first instantiate a bot player!
function AttackObject:New(owner, attack_name)
    assert(
        type(attack_name) == "string",
        "Attack must have a valid name! (given: " .. attack_name .. ", of type: " .. type(attack_name) .. ")"
    )
    assert(
        type(owner) == "table" and (type(owner:GetReference()) == "userdata" or owner.IsBot),
        "Attacks need an owner!"
    )
    self.__index = self
    local obj = setmetatable({}, self)

    obj.Name = attack_name or self.Name
    obj.Running = false

    obj.PhaseChanged = Event:New()
    obj.Started = Event:New()
    obj.Stopped = Event:New()
    obj._FSM = FSM:New()
    obj._maid = Maid.new()
    obj._CurrentPhase = nil
    obj._Phases = self._Phases or {}
    obj._Shared = AttackShared:New() -- passes data between states
    obj.StartTime = math.huge
    obj._maid:GiveTask(obj._FSM)
    obj._maid:GiveTask(obj.Stopped)
    obj._maid:GiveTask(obj.Started)
    obj._maid:GiveTask(obj.PhaseChanged)
    obj._maid:GiveTask(obj._Shared)
    local BaseState = State:New("BASE_ATTACK_STATE", nil, nil, true) -- internal base state for FSM (normally idle case)
    obj._baseState = BaseState
    obj._FSM:AddState(BaseState)

    return obj
end

function AttackObject:AddPhase(phase, next_phase)
    assert(type(phase) == "table", "Phase not an object!")
    assert(self._Phases[phase.Name] == nil, string.format("Phase with name %s already exists!", phase.Name))

    next_phase_name = "BASE_ATTACK_STATE"
    if type(next_phase) == "table" then
        next_phase_name = next_phase.Name
    elseif type(next_phase) == "string" then
        next_phase_name = next_phase
    end
    self._Phases[phase.Name] = phase
    phase._Shared = self._Shared -- passthrough reference to shared data
    -- Register transitions
    if next_phase_name then
        local transition = EventTransition:New(phase.Completed, nil, next_phase_name)
        phase:AddTransition(transition)
    end

    self._FSM:AddState(phase)
end

function AttackObject:GetPhase(phase_name)
    phase_name = string.upper(phase_name)
    for _, phase in pairs(self._Phases) do
        if phase.Name == phase_name then
            return phase
        end
    end
end

function AttackObject:AddLinearPhasePathway(phases)
    local start_phase = phases[1]
    -- Setup transition from base state to first state
    local BaseStateHook = EventTransition:New(self.Started, nil, start_phase.Name) 
    self._baseState:AddTransition(BaseStateHook)
    for key, phase in pairs(phases) do
        local next_phase = phases[key + 1]
        local next_phase_name = (next_phase and next_phase.Name) or nil
        self:AddPhase(phase, next_phase_name)
    end
end

-- Starts an attack
function AttackObject:Start()
    if self.Running then return end
    self.Running = true
    self._maid:GiveTask(
        self._Phases["END"].Unloaded:Connect(
            function()
                self:Stop()
            end
        )
    )
    self.StartTime = _G.Clock:GetTime()
    self._FSM:Start()
    self.Started:Fire()
end

function AttackObject:Stop()
    if not self.Running then return end
    self.Running = false
    self._FSM:Stop()
    self.Stopped:Fire()
    self:Destroy()
end

function AttackObject:Destroy()
    self:Stop()
    self._maid:Destroy()
    self._owner = nil
    self._Phases = nil
    for i, v in pairs(self) do
        self[i] = nil
    end
end

function AttackObject:GetTotalTime()
    local t = 0
    for _, phase in pairs(self._Phases) do
        t = t + phase:GetTotalTime()
    end
    return t
end

return AttackObject
