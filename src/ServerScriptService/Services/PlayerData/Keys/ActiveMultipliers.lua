local TOTAL_MULTIPLIER = "TOTAL_MULTIPLIER"
return {
    DEFAULT_VALUE = {},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "AddMultiplier" then
            assert(action.Category, "Invalid multiplier category!")
            assert(action.Id, "Invalid multiplier id!")
            assert(typeof(action.Multiplier) == "number", "Invalid multiplier " .. tostring(action.Multiplier))
            local multiplierCategory = action.Category
            local multiplierId = action.Id
            local multiplier = action.Multiplier

            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = {}
                local total = 1
                for id, w in pairs(v) do
                    if id ~= TOTAL_MULTIPLIER then
                        if w.Id == multiplierId and w.Multiplier == multiplier then
                            -- already exists!
                            return currentState
                        end
                        newState[k][id] = w
                        total = total + (w.Multiplier - 1)
                    end
                end
                newState[k][TOTAL_MULTIPLIER] = total
            end
            if not newState[multiplierCategory] then
                newState[multiplierCategory] = {
                    [TOTAL_MULTIPLIER] = 1
                }
            end
            newState[multiplierCategory][multiplierId] = {
                Id = multiplierId,
                Multiplier = multiplier
            }
            newState[multiplierCategory][TOTAL_MULTIPLIER] = newState[multiplierCategory][TOTAL_MULTIPLIER] + (multiplier - 1)
            return newState
        elseif action.type == "RemoveMultiplier" then
            assert(action.Id, "Invalid multiplier id!")
            local multiplierId = action.Id
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = {}
                local total = 1
                for id, w in pairs(v) do
                    if id ~= TOTAL_MULTIPLIER then
                        if w.Id ~= multiplierId then
                            newState[k][id] = w
                            total = total + (w.Multiplier - 1)
                        end
                    end
                end
                newState[k][TOTAL_MULTIPLIER] = total
            end
            return newState
        end
    end
}
