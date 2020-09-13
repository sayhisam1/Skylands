return {
    Stateful = true,
    DEFAULT_VALUE = 0,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value, "Invalid Value!")
            return math.floor(action.Value)
        elseif action.type == "Increment" then
            assert(action.Amount, "Invalid Amount!!")
            return math.floor(currentState + action.Amount)
        end
    end
}
