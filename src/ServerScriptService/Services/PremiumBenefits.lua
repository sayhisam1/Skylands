-- stores player inventories --

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData", "InitializeBinders", "Shop"}
Service:AddDependencies(DEPENDENCIES)

local AssetFinder = require(ReplicatedStorage.AssetFinder)

function Service:Load()
    local maid = self._maid

    local function setupPlayer(plr)
        self:Log(3, "Setting up vip for", plr)
        if plr.MembershipType == Enum.MembershipType.Premium then
            self:GivePremium(plr)
        end
    end
    self:HookPlayerAction(setupPlayer)

    maid:GiveTask(
        Players.PlayerMembershipChanged:Connect(
            function(plr)
                if plr.MembershipType == Enum.MembershipType.Premium then
                    self:GivePremium(plr)
                end
            end
        )
    )
    self.Services.PlayerData:RegisterResetHook("OwnedBackpacks", function(plr, store, prev)
        if plr.MembershipType == Enum.MembershipType.Premium then
            self:GivePremium(plr)
        end
    end)
end

function Service:GivePremium(plr)
    self:Log(3, "Giving premium to ", plr)
    local vipPick = AssetFinder.FindPickaxe("Premium Pickaxe")
    local vipBackapck = AssetFinder.FindBackpack("PremiumBackpack")
    local Shop = self.Services.Shop
    Shop:AddAsset(plr, vipPick)
    Shop:AddAsset(plr, vipBackapck)
    local HasRedeemedPremiumBoosts = self.Services.PlayerData:GetStore(plr, "HasRedeemedPremiumBoosts")
    if not HasRedeemedPremiumBoosts:getState() then
        for i = 1, 3, 1 do
            self.Services.Boosts:AddRandomBoost(plr, 5)
        end
        HasRedeemedPremiumBoosts:dispatch({
            type="Set",
            Value=true
        })
    end
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
