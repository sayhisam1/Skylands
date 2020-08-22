--[[
EVENT DRIVEN FSM OBJECT
@public
	FSM.new()
	FSM:GetStateFromName(string state_name)
	FSM:GetCurrentState()
	FSM:SetDefaultState(State state)
	FSM:AddState(string name)
	FSM:ChangeState(string new_state_name)
	FSM:Start()

@private
	FSM:_PushState(State state)
	FSM:_PopState()
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Queue = require(ReplicatedStorage.Objects.Shared.Queue)
local Stack = require(ReplicatedStorage.Objects.Shared.Stack)

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local FSM = setmetatable({}, BaseObject)
FSM.__index = FSM
FSM.ClassName = script.Name

--=CONSTRUCTOR=--
function FSM.new()
	local self = setmetatable(BaseObject.new(), FSM)

	self._registeredStates = {}
	self._stateStack = Stack.new()
	self._eventQueue = Queue.new()
	self._loopingEvents = false
	self._registeredTransitions = {}
	self._stopped = true
	self._maid:GiveTask(self._stateStack)
	self._maid:GiveTask(self._eventQueue)
	return self
end

function FSM:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true
	self:Stop()
	self._maid:Destroy()
end
--=GETTERS=--

-- Responsible for finding the state object related to a specific state_name
-- @param string state_name The name of the state to find
-- @return State The found state (nil if not found)
function FSM:GetStateFromName(state_name)
	local retrieved_state = self._registeredStates[state_name]
	assert(retrieved_state, "Tried to retrieve unknown state " .. state_name .. "!")
	if (retrieved_state == nil) then
		self:Log(1, "TRIED TO GET INVALID STATE " .. state_name)
	end
	return retrieved_state
end

-- Responsible for Getting the current loaded state object
-- @return State The current loaded state (should NEVER be nil!)
function FSM:GetCurrentState()
	self:Log(1, "GET CURR STATE", self._stateStack:Peek().Name)
	return self._stateStack:Peek()
end

--=SETTERS=--

-- Responsible for Setting the default state of the FSM; This state should never be unloaded, if it is reached.
-- @param State state the State object corresponding to the default state to be Set
function FSM:SetDefaultState(state)
	while (not self._stateStack:IsEmpty()) do
		self._stateStack:Pop()
	end
	self._stateStack:Push(state)
end

-- Responsible for creating and Adding a state to the known states for the FSM
-- @param string name The name of the state (Should be all capital letters, and a verb; IE: SPRINTING, WALKING, etc..)
-- @param function on_load The function that should be called when the state is loaded
-- @param function on_unload The function that should be called when the state is unloaded
-- @return State An instance of the state object, corresponding to the given FSM
function FSM:AddState(state)
	self._maid:GiveTask(state)
	if (state:IsDefault()) then
		self:SetDefaultState(state)
	end
	for i, v in pairs(state.Transitions) do
		self:_RegisterTransition(v)
	end
	self._maid:GiveTask(
		state.TransitionAdded:Connect(
			function(...)
				self:_RegisterTransition(...)
			end
		)
	)

	self._maid:GiveTask(
		state.StateChanged:Connect(
			function(...)
				self:ChangeState(...)
			end
		)
	)
	self._registeredStates[state.Name] = state
	return state
end

-- Responsible for changing the currently loaded state to the new passed state
-- @param string new_state_name The name of the new state to be loaded (If this is PREV, then the state will merely load the last state on the stack)
function FSM:ChangeState(new_state_name, ...)
	self._changingState = true
	self:Log(1, "CHANGING STATE FROM " .. self:GetCurrentState().Name .. " TO " .. new_state_name)
	self._stateStack:Peek():Unload()
	if (new_state_name ~= "PREV") then
		local new_state_obj = self:GetStateFromName(new_state_name)
		self:_PushState(new_state_obj, ...)
	else
		--return to the previous state
		if (self._stateStack:GetSize() > 1) then
			self:_PopState()
		end
	end
	if (not self._stateStack:Peek()) then
		self:Log(1, "STATE STACK EMPTY!")
	end

	self:Log(1, "LOADING STATE ", self._stateStack:Peek())
	self._stateStack:Peek():Load()
	self._changingState = false
end

-- Responsible for starting the actual FSM ( loads the default state )
function FSM:Start()
	assert(self._stopped, "Cannot start a currently started FSM!")
	self._stopped = false
	self._stateStack:Peek():Load()
end

function FSM:Stop()
	--assert(not self._stopped,"Cannot stop a _stopped FSM!")
	self._stopped = true
	while (self._changingState) do
		wait()
	end
	local top = self:_PopState()
	if top then
		top:Unload()
	end -- unload top state
	while (self:_PopState()) do
	end
	self:_ClearEventQueue()
end

--PRIVATE FUNCTIONS--

-- Responsible for moving the current internal stack
function FSM:_PushState(state)
	self._stateStack:Push(state)
end

-- Responsible for moving down the current internal stack (will not pop the default state)
function FSM:_PopState()
	if self._stateStack:GetSize() > 1 then
		return self._stateStack:Pop()
	end
end

-- Responsible for handling the message queue
function FSM:_StartPopEventQueue()
	if (self._stopped or self._loopingEvents) then
		return
	end
	self._loopingEvents = true

	while (not self._eventQueue:IsEmpty()) do
		local deq = self._eventQueue:Dequeue()
		self:Log(1, "EVQ POP")
		self:GetCurrentState():PushEvent(unpack(deq))
	end

	self._loopingEvents = false
end

function FSM:_ClearEventQueue()
	while (self._eventQueue:Dequeue()) do
	end
	self._loopingEvents = false
end

-- Responsible for binding the signal to the fsm (used to prevent cases where events occur mid state transition)
function FSM:_RegisterTransition(transition)
	if self._registeredTransitions[transition.Id] then
		return --Already binded!
	end
	local connector =
		transition.Event:Connect(
		function(...)
			if (not self._stopped) then
				self:Log(1, "TRANSITION EVENT RECV", transition.NextState)
				self._eventQueue:Enqueue({transition.Id, {...}})
				self:_StartPopEventQueue()
			end
		end
	)
	self._maid:GiveTask(connector)
	self._maid:GiveTask(transition)
	self._registeredTransitions[transition.Id] = connector
end
return FSM
