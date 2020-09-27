local module = {}
module.CalculateCost = function(n)
    n = n + 1
    local cost = 1E6 * n ^ 2
    return cost
end

module.CalculateMultipliers = function(n)
    local multipliers = {
        Gold = 1 + (.5 * n)
    }
    return multipliers
end

module.CalculateTickets = function(n)
    n = n + 1
    return 100
end

return module
