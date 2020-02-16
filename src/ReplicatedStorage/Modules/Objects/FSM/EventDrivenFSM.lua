--[[
EVENT DRIVEN FSM OBJECT	
@public
	FSM.New()
	FSM:GetStateFromName(string state_name)
	FSM:GetCurrentState()
	FSM:SetDefaultState(State state)
	FSM:AddState(string name)
	FSM:ChangeState(string new_state_name)
	FSM:Start()
	
@private
	FSM:PushState(State state)
	FSM:PopState()
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Queue = require("Queue")
local Stack = require("Stack")
local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)
local Debug = require("Debugger")

local FSM = {
	Stack = nil,
	_RegisteredStates = {},
	_EventQueue = {},
	_RegisteredTransitions = {},
	_stopped = true
}

--=CONSTRUCTOR=--
function FSM:New()
	self.__index = self
	local obj = setmetatable({}, self)

	obj._debugger = Debug:New()
	obj._RegisteredStates = {}
	obj._StateStack = Stack:New()
	obj._EventQueue = Queue:New()
	obj._loopingEvents = false
	obj._RegisteredTransitions = {}
	obj._stopped = true
	obj._stateChangedEvent = Event:New()
	return obj
end

function FSM:Destroy()
	self:Stop()
	for i, v in pairs(self._RegisteredStates) do
		v:Destroy()
		self._RegisteredStates[i] = nil
	end
	self._RegisteredStates = nil
	for i, v in pairs(self._RegisteredTransitions) do
		v:Disconnect()
		self._RegisteredTransitions[i] = nil
	end
	self._RegisteredTransitions = nil
	for i, v in pairs(self) do
		if type(v) == "table" and type(v.Destroy) == "function" then
			v:Destroy()
		end
		self[i] = nil
	end
end
--=GETTERS=--

-- Responsible for finding the state object related to a specific state_name
-- @param string state_name The name of the state to find
-- @return State The found state (nil if not found)
function FSM:GetStateFromName(state_name)
	local retrieved_state = self._RegisteredStates[state_name]
	assert(retrieved_state, "Tried to retrieve unknown state " .. state_name .. "!")
	if (retrieved_state == nil) then
		self._debugger:printd(0, "TRIED TO GET INVALID STATE " .. state_name)
	end
	return retrieved_state
end

-- Responsible for Getting the current loaded state object
-- @return State The current loaded state (should NEVER be nil!)
function FSM:GetCurrentState()
	self._debugger:printd(0, "GET CURR STATE", self._StateStack:Peek().Name)
	return self._StateStack:Peek()
end

--=SETTERS=--

-- Responsible for Setting the default state of the FSM; This state should never be unloaded, if it is reached.
-- @param State state the State object corresponding to the default state to be Set
function FSM:SetDefaultState(state)
	while (not self._StateStack:IsEmpty()) do
		self._StateStack:Pop()
	end
	self._StateStack:Push(state)
end

-- Responsible for creating and Adding a state to the known states for the FSM
-- @param string name The name of the state (Should be all capital letters, and a verb; IE: SPRINTING, WALKING, etc..)
-- @param function on_load The function that should be called when the state is loaded
-- @param function on_unload The function that should be called when the state is unloaded
-- @return State An instance of the state object, corresponding to the given FSM
function FSM:AddState(state)
	if (state:IsDefault()) then
		self:SetDefaultState(state)
	end
	for i, v in pairs(state.Transitions) do
		self:RegisterTransition(v)
	end
	state.TransitionAdded:Connect(
		function(...)
			self:RegisterTransition(...)
		end
	)

	state.StateChanged:Connect(
		function(...)
			self:ChangeState(...)
		end
	)
	self._RegisteredStates[state.Name] = state
	state.Debug.LEVEL = self._debugger.LEVEL
	return state
end

-- Responsible for changing the currently loaded state to the new passed state
-- @param string new_state_name The name of the new state to be loaded (If this is PREV, then the state will merely load the last state on the stack)
function FSM:ChangeState(new_state_name, ...)
	self._changingState = true
	self._debugger:printd(0, "CHANGING STATE FROM " .. self:GetCurrentState().Name .. " TO " .. new_state_name)
	self._StateStack:Peek():Unload()
	if (new_state_name ~= "PREV") then
		local new_state_obj = self:GetStateFromName(new_state_name)
		self:PushState(new_state_obj, ...)
	else
		--return to the previous state
		if (self._StateStack:GetSize() > 1) then
			self:PopState()
		end
	end
	if (not self._StateStack:Peek()) then
		self._debugger:printd(0, "STATE STACK EMPTY!")
	end

	self._debugger:printd(0, "LOADING STATE ", self._StateStack:Peek())
	self._StateStack:Peek():Load()
	self._stateChangedEvent:Fire(self._StateStack:Peek().Name)
	self._changingState = false
end

-- Responsible for starting the actual FSM ( loads the default state )
function FSM:Start()
	assert(self._stopped, "Cannot start a currently started FSM!")
	self._stopped = false
	self._StateStack:Peek():Load()
end

function FSM:Stop()
	--assert(not self._stopped,"Cannot stop a _stopped FSM!")
	self._stopped = true
	while (self._changingState) do
		wait()
	end
	local top = self:PopState()
	if top then
		top:Unload()
	end -- unload top state
	while (self:PopState()) do
	end
	self:ClearEventQueue()
end

--PRIVATE FUNCTIONS--

-- Responsible for moving the current internal stack
function FSM:PushState(state)
	self._StateStack:Push(state)
end

-- Responsible for moving down the current internal stack (will not pop the default state)
function FSM:PopState()
	if self._StateStack:GetSize() > 1 then
		return self._StateStack:Pop()
	else
		--self._debugger:printd(0,"CANNOT POP DEFAULT STATE!","Error")
	end
end

-- Responsible for handling the message queue
function FSM:StartPopEventQueue()
	if (self._stopped or self._loopingEvents) then
		return
	end
	self._loopingEvents = true

	while (not self._EventQueue:IsEmpty()) do
		local deq = self._EventQueue:Dequeue()
		self._debugger:printd(0, "EVQ POP")
		self:GetCurrentState():PushEvent(unpack(deq))
	end

	self._loopingEvents = false
end

function FSM:ClearEventQueue()
	while (self._EventQueue:Dequeue()) do
	end
	self._loopingEvents = false
end

-- Responsible for binding the signal to the fsm (used to prevent cases where events occur mid state transition)
function FSM:RegisterTransition(transition)
	if self._RegisteredTransitions[transition.Id] then
		return --Already binded!
	end
	self._RegisteredTransitions[transition.Id] =
		transition.Event:Connect(
		function(...)
			if (not self._stopped) then
				self._debugger:printd(0, "TRANSITION EVENT RECV", transition.NextState)
				self._EventQueue:Enqueue({transition.Id, {...}})
				self:StartPopEventQueue()
			end
		end
	)
end
return FSM
