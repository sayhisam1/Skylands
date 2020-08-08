local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PETS = ReplicatedStorage:WaitForChild("Pets")

local Util
local custom_type = {
    Transform = function(text)
        local finder = Util.MakeFuzzyFinder(PETS)
        return finder(text)
    end,
    Autocomplete = function(pets)
        return Util.GetNames(pets)
    end,
    Validate = function(pets)
        return #pets > 0, "No pets with that name could be found."
    end,
    Parse = function(pets)
        return pets[1]
    end
}

return function(registry)
    Util = registry.Cmdr.Util
    registry:RegisterType("pet", custom_type)
end
