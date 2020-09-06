
local module = {}
module.CalculateCost = function(n)
    local cost = 1E6 * n^2
    return cost
end

module.CalculateMultipliers = function(n)
    local multipliers = {
        Gold = 1 + (.5 * n)
    }
    return multipliers
end

return module