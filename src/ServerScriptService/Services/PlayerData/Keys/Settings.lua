local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local tbl
tbl = {
    Stateful = true,
    DEFAULT_VALUE = {
        Music = true
    },
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value and typeof(action.Value) == "table", "Invalid Value!")
            return action.Value
        elseif action.type == "SetSetting" then
            assert(action.Setting and tbl.DEFAULT_VALUE[action.Setting] ~= nil, "Invalid setting " .. action.Setting)
            assert(typeof(action.Value) == typeof(tbl.DEFAULT_VALUE[action.Setting]), "Invalid value!")
            -- clone state --
            local newState = TableUtil.shallow(currentState)
            newState[action.Setting] = action.Value
            return newState
        end
    end
}

return tbl
