local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)
local keys = {}

keys.Gold = {
    Stateful = true,
    DEFAULT_VALUE = 0,
    Ordered = true,
    Leaderstat = true,
    LeaderstatName = "Gold 💰",
    LeaderstatFunction = function(num)
        return NumberToStr(num)
    end,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.value, "Invalid Value!")
            return math.floor(action.value)
        elseif action.type == "IncrementGold" then
            assert(action.amount, "Invalid amount!")
            return math.floor(currentState + action.amount)
        elseif action.type == "DecrementGold" then
            assert(action.amount, "Invalid amount!")
            local new = math.floor(currentState - action.amount)
            return new
        end
    end
}

local ret = {}

ret.Keys = keys
function ret.incrementGold(amount)
    assert(typeof(amount) == "number" and amount >= 0, "Invalid amount!")
    return {
        type = "IncrementGold",
        amount = amount
    }
end
function ret.decrementGold(amount)
    assert(typeof(amount) == "number" and amount >= 0, "Invalid amount!")
    return {
        type = "DecrementGold",
        amount = amount
    }
end

return ret
