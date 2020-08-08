-- 			TRANSITION BASE CLASS 				--
-- Defines base structure of a state transition --

local Transition = require(script.Parent.Transition)
local EventTransition = Transition.new()
EventTransition.__index = EventTransition
EventTransition.ClassName = script.Name

function EventTransition.new(event, func, next_state, ...)
    assert(event and type(event.Connect) == "function", "Invalid event passed! (type:" .. type(event) .. "!)")
    func = func or function(...)
            return true
        end
    local self = setmetatable(Transition.new(func, next_state), EventTransition)

    self.TransitionEvent = event

    event:Connect(
        function(...)
            self:CheckTransition(...)
        end
    )

    return self
end

return EventTransition
