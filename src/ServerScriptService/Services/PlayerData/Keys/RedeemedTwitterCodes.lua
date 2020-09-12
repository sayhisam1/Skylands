return {
    Stateful = true,
    DEFAULT_VALUE = {},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        elseif action.type == "AddItem" then
            assert(action.Item, "Invalid Item!")
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
            end
            newState[action.Item] = true
            return newState
        elseif action.type == "RemoveItem" then
            assert(action.Item, "Invalid Item!")
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
            end
            newState[action.Item] = nil
            return newState
        end
    end
}
