-- 			TRANSITION BASE CLASS 				--
-- Defines base structure of a state transition --

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Transition = require(ReplicatedStorage.Modules.Objects.FSM.Transition)
local EventTransition = Transition:New()

function EventTransition:New(event, func, next_state, ...)
    assert(event and type(event.Connect) == "function", "Invalid event passed! (type:" .. type(event) .. "!)")
    self.__index = self
    func = func or function(...)
            return true
        end
    local newobj = setmetatable(Transition:New(func, next_state), self)

    newobj.TransitionEvent = event

    event:Connect(
        function(...)
            newobj:CheckTransition(...)
        end
    )

    return newobj
end

return EventTransition
