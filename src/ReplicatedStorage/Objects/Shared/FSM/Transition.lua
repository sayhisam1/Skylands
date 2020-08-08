-- 			TRANSITION BASE CLASS 				--
-- Defines base structure of a state transition --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local Event = require(ReplicatedStorage.Objects.Shared.Event)
local Transition = {
    NextState = nil,
    TransitionFunction = nil
}
Transition.__index = Transition
Transition.ClassName = script.Name

--=CONSTRUCTOR=--
function Transition.new(func, next_state, ...)
    local self = setmetatable({}, Transition)

    self.Id = HttpService:GenerateGUID(false) -- unique identifier for transition
    self.Event = Event.new() -- triggered when state change condition is met (hooked by FSM)
    self.NextState = next_state -- name of next state to change to

    self.TransitionFunction = func -- function that determines if the transition should occur (called by parent state)

    return self
end

function Transition:CheckTransition(...)
    self.Event:Fire(...)
end
function Transition:SetOnLoadCheck(func)
    self.OnLoadCheck = func -- determines if the transition should occur when the state is first loaded (i.e. check for existing transition state)
end

function Transition:TryOnLoad(...)
    if (self.OnLoadCheck) then
        return self.OnLoadCheck(...)
    end
    return false
end
function Transition:Destroy()
    for i, v in pairs(self) do
        if type(v) == "table" and type(v.Destroy) == "function" then
            v:Destroy()
        end
        self[i] = nil
    end
end
return Transition
