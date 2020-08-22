return {
    Stateful = true,
    DEFAULT_VALUE = {},
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.Value and typeof(action.Value) == "table", "Invalid Value!")
            return action.Value
        elseif action.type == "AddPet" then
            assert(action.Data, "No data to store!!")
            assert(action.Data.Id, "No id!")
            assert(action.Data.PetClass, "Pet did not have a petclass!")
            local data = action.Data
            local id = data.Id
            assert(not currentState[id], "Id already exists!")
            -- clone state --
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
            end
            newState[id] = data
            return newState
        elseif action.type == "UpdatePet" then
            assert(action.Data, "No data to store!!")
            assert(action.Data.Id, "No id!")
            assert(action.Data.PetClass, "Pet did not have a petclass!")
            local data = action.Data
            local id = data.Id
            -- clone state --
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
            end
            newState[id] = data
            return newState
        elseif action.type == "SelectPet" then
            assert(action.Id, "Pet has no id!")
            local id = action.Id
            -- clone state --
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
                if k == id then
                    v.Selected = true
                end
            end
            return newState
        elseif action.type == "UnselectPet" then
            assert(action.Id, "Pet has no id!")
            local id = action.Id
            -- clone state --
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
                if k == id then
                    v.Selected = nil
                end
            end
            return newState
        elseif action.type == "RemovePet" then
            assert(action.Id, "Pet has no id!")
            local id = action.Id
            if not currentState[id] then
                return currentState
            end
            -- clone state --
            local newState = {}
            for k, v in pairs(currentState) do
                newState[k] = v
            end
            newState[id] = nil
            return newState
        end
    end
}
