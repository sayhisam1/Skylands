local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

return {
    DEFAULT_VALUE = {},
    Stateful = true,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "AddBoostTime" then
            assert(action.Category, "Invalid boost category!")
            assert(typeof(action.Time) == "number", "Invalid boost!")
            assert(typeof(action.Multiplier) == "number", "Invalid Multiplier!")
            local boostCategory = action.Category
            local boostTime = action.Time
            local boostMultiplier = action.Multiplier

            local newState = currentState
            if not newState[boostCategory] then
                newState[boostCategory] = {
                    RemainingTime = 0,
                    Multiplier = boostMultiplier
                }
            end
            newState[boostCategory].RemainingTime = newState[boostCategory].RemainingTime + boostTime
            return newState
        elseif action.type == "ReduceBoostTime" then
            assert(action.Category, "Invalid boost category!")
            assert(typeof(action.Time) == "number", "Invalid boost!")
            local boostCategory = action.Category
            local boostTime = action.Time

            local newState = currentState
            if not newState[boostCategory] then
                newState[boostCategory] = {
                    RemainingTime = 0,
                    Multiplier = 1
                }
            end
            newState[boostCategory].RemainingTime = math.max(0, newState[boostCategory].RemainingTime - boostTime)
            return newState
        end
    end
}
