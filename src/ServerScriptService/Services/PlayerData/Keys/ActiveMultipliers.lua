return {
    DEFAULT_VALUE = {},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "AddMultiplier" then
            assert(action.Category, "Invalid multiplier category!")
            assert(action.Id, "Invalid multiplier id!")
            assert(typeof(action.Multiplier) == "number", "Invalid multiplier!")
            local multiplierCategory = action.Category
            local muliplierId = action.Id
            local multiplier = aciton.Multiplier

            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = {}
                for id, w in pairs(v) do
                    if w.Id == multiplierId then
                        return currentState
                    end
                    newState[k][id] = w
                end
            end
            if not newState[multiplierCategory] then
                newState[multiplierCategory] = {}
            end
            newState[multiplierCategory][multiplierId] = {
                Id = muliplierId,
                Multiplier = multiplier
            }
            return newState
        elseif action.type == "RemoveMultiplier" then
            assert(action.Id, "Invalid multiplier id!")
            local muliplierId = action.Id
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = {}
                for id, w in pairs(v) do
                    if w.Id ~= multiplierId then
                        newState[k][id] = w
                    end
                end
            end
            return newState
        end
    end
}
