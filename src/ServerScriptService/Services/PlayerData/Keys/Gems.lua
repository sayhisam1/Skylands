local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

return {
    Stateful = true,
    DEFAULT_VALUE = 0,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return math.floor(action.Value)
        elseif action.type == "Increment" then
            assert(action.Amount, "Invalid Amount!!")
            return math.floor(currentState + action.Amount)
        elseif action.type == "Decrement" then
            assert(action.Amount, "Invalid Amount!!")
            local new = math.floor(currentState - action.Amount)
            if new < 0 then
                error({code = Enums.Errors.NotEnoughGems}, 2)
            end
            return new
        end
    end
}
