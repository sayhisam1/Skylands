return function(fabric)
    return {
        name = "Ore",
        tag = "Ore",
        components = {
            Replicated = {}
        },
        defaults = {
            maxHealth = 0,
            mineable = false,
            baseModel = nil
        },
        onInitialize = function(self)
        end,
        onAdded = function(self)
            self:addLayer(
                "maxHealth",
                {
                    maxHealth = self:get("health")
                }
            )
        end,
        effects = {}
    }
end
