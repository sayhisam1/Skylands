return {
    Stateful = true,
    DEFAULT_VALUE = {"BasicBackpack"},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "AddItem" then
            assert(action.Item, "Invalid Item!")
            local newState = {}
            for _, v in pairs(currentState) do
                if v == action.Item then
                    return currentState
                end
                newState[#newState + 1] = v
            end
            newState[#newState + 1] = action.Item
            return newState
        elseif action.type == "RemoveItem" then
            assert(action.Item, "Invalid Item!")
            local newState = {}
            for _, v in pairs(currentState) do
                if v ~= action.Item then
                    newState[#newState + 1] = v
                end
            end
            return newState
        end
    end
}
