return {
    Stateful = true,
    DEFAULT_VALUE = 0,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return action.Value
        end
    end
}
