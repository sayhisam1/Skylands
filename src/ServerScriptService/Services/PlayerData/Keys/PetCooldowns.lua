local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
return {
    Stateful = true,
    DEFAULT_VALUE = {},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value and typeof(action.Value) == "table", "Invalid Value!")
            return action.Value
        elseif action.type == "AddTime" then
            assert(action.Id, "No id!")
            assert(action.Ability, "No ability!")
            assert(action.Time, "No time!")
            local id = action.Id
            local abilityName = action.Ability
            local newTime = action.Time
            -- clone state --
            local newState = {}
            for petId, cooldowns in pairs(currentState) do
                newState[petId] = {}
                for name, t in pairs(cooldowns) do
                    newState[petId][name] = t
                end
            end
            if not newState[id] then
                newState[id] = {}
            end
            newState[id][abilityName] = newTime
            return newState
        elseif action.type == "ClearTime" then
            assert(action.Id, "No id!")
            assert(action.Ability, "No ability!")
            local id = action.Id
            local abilityName = action.Ability
            -- clone state --
            local newState = {}
            for petId, cooldowns in pairs(currentState) do
                newState[petId] = {}
                for name, t in pairs(cooldowns) do
                    newState[petId][name] = t
                end
            end

            if newState[id] then
                newState[id][abilityName] = nil
                if TableUtil.len(newState[id]) == 0 then
                    newState[id] = nil
                end
            end

            return newState
        end
    end
}
