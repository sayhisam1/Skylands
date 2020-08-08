local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local Event = require(ReplicatedStorage.Objects.Shared.Event)

local State =
    setmetatable(
    {
        Name = nil,
        Transitions = {},
        Loaded = false,
        IsDefaultState = false
    },
    BaseObject
)

State.__index = State

--=CONSTRUCTOR=--
-- Responsible for creating a new instance of a State object, corresponding to the given FSM
-- @param string name The name of the state (Should be all capital letters, and a verb; IE: SPRINTING, WALKING, etc..)
-- @param function on_load The function that should be called when the state is loaded
-- @param function on_unload The function that should be called when the state is unloaded
-- @return State An instance of the state object, corresponding to the given FSM
function State.new(name, on_load, on_unload, is_default)
    local self = setmetatable(BaseObject.new(name), State)

    self.Name = name
    self.Loaded = Event.new()
    self._maid:GiveTask(self.Loaded)
    self.Unloaded = Event.new()
    self._maid:GiveTask(self.Unloaded)
    if (on_load) then
        self._maid:GiveTask(self.Loaded:Connect(on_load))
    end
    if (on_unload) then
        self._maid:GiveTask(self.Unloaded:Connect(on_unload))
    end

    self.StateChanged = Event.new()
    self._maid:GiveTask(self.StateChanged)
    self.TransitionAdded = Event.new()
    self._maid:GiveTask(self.TransitionAdded)
    self.Transitions = {}

    self:SetDefault(is_default)
    self.__loaded = false

    return self
end

-- Responsible for adding a transition object to the state; The transition object specifies how this State will change into another State
-- @param Transition transition The transition that is to be added to the state
-- @return void
function State:AddTransition(transition)
    self.TransitionAdded:Fire(transition)
    self.Transitions[transition.Id] = transition
    self._maid:GiveTask(transition)
end

function State:PushEvent(event_id, vars)
    local transition = self.Transitions[event_id]

    if transition then
        self:Log(1, 0, "STATE ", self.Name, "RECV PUSH EVENT", event_id, transition.Id)
        if (transition.TransitionFunction and transition.TransitionFunction(unpack(vars))) then
            self:Log(1, 0, "STATE ", self.Name, "FIRE CHANGED TO", transition.NextState)
            self.StateChanged:Fire(transition.NextState, event_id)
        end
    end
end

-- Responsible for loading the state; Includes calling the function OnLoadFunction, and binding all transitions
function State:Load(...)
    for _, transition in pairs(self.Transitions) do
        if transition:TryOnLoad() then
            self.StateChanged:Fire(transition.NextState)
            return false
        end
    end
    self.Loaded:Fire(...)

    self.__loaded = true
    return true
    --self.Debug("DONE LOADING STATE "..self.Name)
end

-- Similar to load, responsible for unloading the state when the FSM calls State:Unload(). Also unbinds all added events.
function State:Unload(...)
    if (self.__loaded == false) then
        return
    end
    self.__loaded = false
    self.Unloaded:Fire(...)
end

function State:SetDefault(val)
    self.IsDefaultState = val
end
function State:IsDefault()
    return self.IsDefaultState
end
return State
