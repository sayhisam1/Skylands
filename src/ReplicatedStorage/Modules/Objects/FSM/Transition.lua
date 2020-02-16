-- 			TRANSITION BASE CLASS 				--
-- Defines base structure of a state transition --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HttpService = game:GetService("HttpService")
local Event = require()
local Transition = {
    NextState = nil,
    TransitionFunction = nil
}
--=CONSTRUCTOR=--

function Transition:New(func, next_state, ...)
    self.__index = self
    local obj = setmetatable({}, self)

    obj.Id = HttpService:GenerateGUID(false) -- unique identifier for transition
    obj.Event = Event:New() -- triggered when state change condition is met (hooked by FSM)
    obj.NextState = next_state -- name of next state to change to

    obj.TransitionFunction = func -- function that determines if the transition should occur (called by parent state)

    return obj
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
