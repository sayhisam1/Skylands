return {
    Stateful = true,
    DEFAULT_VALUE = false,
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value ~= nil, "Invalid Value"..tostring(action.Value))
            assert(typeof(action.Value) == 'boolean', "Invalid type "..typeof(action.Value))
            return action.Value
        end
    end
}
