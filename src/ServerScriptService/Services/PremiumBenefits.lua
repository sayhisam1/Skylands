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
    self:Log(3, "Giving vip to ", plr)
    local vipPick = AssetFinder.FindPickaxe("VIPPickaxe")
    local vipBackapck = AssetFinder.FindBackpack("PremiumBackpack")
    local Shop = self.Services.Shop
    Shop:AddAsset(plr, vipPick)
    Shop:AddAsset(plr, vipBackapck)
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
