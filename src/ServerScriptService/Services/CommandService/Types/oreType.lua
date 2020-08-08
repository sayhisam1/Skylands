local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ORES = ReplicatedStorage:WaitForChild("Ores")

local Util
local custom_type = {
    Transform = function(text)
        local finder = Util.MakeFuzzyFinder(ORES)
        return finder(text)
    end,
    Autocomplete = function(ores)
        return Util.GetNames(ores)
    end,
    Validate = function(ores)
        return #ores > 0, "No ores with that name could be found."
    end,
    Parse = function(ores)
        return ores[1]
    end
}

return function(registry)
    Util = registry.Cmdr.Util
    registry:RegisterType("ore", custom_type)
end
