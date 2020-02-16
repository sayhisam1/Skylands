local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)
local Debugger = require("Debugger")

local State = {
    Name = nil,
    Transitions = {},
    Loaded = false,
    IsDefaultState = false
}

--=CONSTRUCTOR=--
-- Responsible for creating a new instance of a State object, corresponding to the given FSM
-- @param string name The name of the state (Should be all capital letters, and a verb; IE: SPRINTING, WALKING, etc..)
-- @param function on_load The function that should be called when the state is loaded
-- @param function on_unload The function that should be called when the state is unloaded
-- @return State An instance of the state object, corresponding to the given FSM
function State:New(name, on_load, on_unload, is_default)
    self.__index = self
    local obj = setmetatable({}, State)

    obj.Debug = Debugger:New()
    obj.Name = name
    obj.Loaded = Event:New()
    obj.Unloaded = Event:New()
    if (on_load) then
        obj.Loaded:Connect(on_load)
    end
    if (on_unload) then
        obj.Unloaded:Connect(on_unload)
    end

    obj.StateChanged = Event:New()
    obj.TransitionAdded = Event:New()
    obj.Transitions = {}

    obj:SetDefault(is_default)
    obj.__loaded = false

    return obj
end

-- Responsible for adding a transition object to the state; The transition object specifies how this State will change into another State
-- @param Transition transition The transition that is to be added to the state
-- @return void
function State:AddTransition(transition)
    self.TransitionAdded:Fire(transition)
    self.Transitions[transition.Id] = transition
end

function State:PushEvent(event_id, vars)
    local transition = self.Transitions[event_id]

    if transition then
        self.Debug:printd(0, "STATE ", self.Name, "RECV PUSH EVENT", event_id, transition.Id)
        if (transition.TransitionFunction and transition.TransitionFunction(unpack(vars))) then
            self.Debug:printd(0, "STATE ", self.Name, "FIRE CHANGED TO", transition.NextState)
            self.StateChanged:Fire(transition.NextState, event_id)
        end
    end
end

-- Responsible for loading the state; Includes calling the function OnLoadFunction, and binding all transitions
function State:Load(...)
    --self.Debug("LOADING STATE "..self.Name)
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
    --self.Debug("UNLOADING STATE "..self.Name)
    if (self.__loaded == false) then
        return
    end
    self.__loaded = false
    self.Unloaded:Fire(...)

    --self.Debug("DONE UNLOADING STATE "..self.Name)
end

function State:Destroy()
    for i, v in pairs(self.Transitions) do
        v:Destroy()
        self[i] = nil
    end
    self.Transitions = nil
    for i, v in pairs(self) do
        if type(v) == "table" and type(v.Destroy) == "function" then
            v:Destroy()
        end
        self[i] = nil
    end
end
function State:SetDefault(val)
    self.IsDefaultState = val
end
function State:IsDefault()
    return self.IsDefaultState
end
return State
