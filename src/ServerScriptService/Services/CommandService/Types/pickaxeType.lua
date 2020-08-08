local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")

local Util
local custom_type = {
    Transform = function(text)
        local finder = Util.MakeFuzzyFinder(PICKAXES)
        return finder(text)
    end,
    Autocomplete = function(pickaxes)
        return Util.GetNames(pickaxes)
    end,
    Validate = function(pickaxes)
        return #pickaxes > 0, "No pickaxes with that name could be found."
    end,
    Parse = function(pickaxes)
        return pickaxes[1]
    end
}

return function(registry)
    Util = registry.Cmdr.Util
    registry:RegisterType("pickaxe", custom_type)
end
