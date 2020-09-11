local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)
local CalculateRebirth = require(ReplicatedStorage.StoreWrappers.CalculateRebirth)
local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)

local REBIRTH_ID = "REBIRTH_MULT"
function Service:Load()
    self:HookPlayerAction(
        function(plr)
            local rebirths = self.Services.PlayerData:GetStore(plr, "Rebirths")
            rebirths.changed:connect(
                function(new, old)
                    self:AddRebirthMultipliers(plr, new)
                end
            )
            self:AddRebirthMultipliers(plr, rebirths:getState())
        end
    )
    local nc = self:GetNetworkChannel()
    nc:Subscribe(
        "TryRebirth",
        function(plr)
            self:Log(3, plr, "Trying rebirth")
            local rebirths = self.Services.PlayerData:GetStore(plr, "Rebirths")
            local cost = CalculateRebirth.CalculateCost(rebirths:getState())
            local gold = self.Services.PlayerData:GetStore(plr, "Gold")
            if gold:getState() >= cost then
                self.Services.PlayerData:ResetPlayerDataKey(plr, "BackpackGoldValue")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "BackpackCapacity")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "Gold")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "SelectedPickaxe")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "OwnedPickaxes")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "SelectedBackpack")
                self.Services.PlayerData:ResetPlayerDataKey(plr, "OwnedBackpacks")
                rebirths:dispatch(
                    {
                        type = "Increment",
                        Amount = 1
                    }
                )
            end
        end
    )
end

function Service:AddRebirthMultipliers(plr, rebirths)
    local multipliers = self.Services.PlayerData:GetStore(plr, "ActiveMultipliers")
    multipliers:dispatch(
        {
            type = "RemoveMultiplier",
            Id = REBIRTH_ID
        }
    )
    local newMultipliers = CalculateRebirth.CalculateMultipliers(rebirths)
    for category, mult in pairs(newMultipliers) do
        Multipliers.AddPlayerMultiplier(plr, category, mult, REBIRTH_ID)
    end
end

return Service
