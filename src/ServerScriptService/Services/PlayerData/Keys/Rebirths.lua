local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)

return {
    Stateful = true,
    DEFAULT_VALUE = 0,
    Ordered = true,
    Leaderstat = true,
    LeaderstatName = "Rebirths 👼",
    LeaderstatFunction = function(num)
        return NumberToStr(num)
    end,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "Increment" then
            assert(action.Amount, "Invalid Amount!!")
            return currentState + action.Amount
        end
    end
}
