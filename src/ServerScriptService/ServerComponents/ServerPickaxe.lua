local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Objects.Maid)

return function(fabric)
    return {
        name = "Pickaxe",
        tag = "Pickaxe",
        components = {
            Replicated = {}
        },
        defaults = {
            damage = 0
        },
        onInitialize = function(self)
            self._maid = Maid.new()
        end,
        onAdded = function(self)
            self:addLayer(
                "maxHealth",
                {
                    maxHealth = self:get("health")
                }
            )
        end,
        effects = {
            equip = function(self)
                local char = self:get("character")
                if char then
                    local rightHand = char:FindFirstChild("RightHand")
                    print(rightHand)
                end
            end
        }
    }
end
