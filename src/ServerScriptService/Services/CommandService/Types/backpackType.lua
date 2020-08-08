local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")

local Util
local custom_type = {
    Transform = function(text)
        local finder = Util.MakeFuzzyFinder(BACKPACKS)
        return finder(text)
    end,
    Autocomplete = function(backpacks)
        return Util.GetNames(backpacks)
    end,
    Validate = function(backpacks)
        return #backpacks > 0, "No backpacks with that name could be found."
    end,
    Parse = function(backpacks)
        return backpacks[1]
    end
}

return function(registry)
    Util = registry.Cmdr.Util
    registry:RegisterType("backpack", custom_type)
end
