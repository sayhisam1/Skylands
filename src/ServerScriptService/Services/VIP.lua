-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData", "InitializeBinders", "Shop", "Boosts"}
Service:AddDependencies(DEPENDENCIES)

local AssetFinder = require(ReplicatedStorage.AssetFinder)

function Service:Load()
    local maid = self._maid
    local PlayerData = self.Services.PlayerData

    local function setupPlayer(plr)
        self:Log(3, "Setting up vip for", plr)
        local IsVipStore = PlayerData:GetStore(plr, "IsVip")
        maid:GiveTask(
            IsVipStore.changed:connect(
                function(new)
                    if new == true then
                        self:GiveVip(plr)
                    end
                end
            )
        )
        if IsVipStore:getState() then
            self:GiveVip(plr)
        end
    end
    self:HookPlayerAction(setupPlayer)
    self.Services.PlayerData:RegisterResetHook(
        "OwnedBackpacks",
        function(plr, store, prev)
            local IsVipStore = PlayerData:GetStore(plr, "IsVip")
            if IsVipStore:getState() then
                self:GiveVip(plr)
            end
        end
    )
end

function Service:GiveVip(plr)
    self:Log(3, "Giving vip to ", plr)
    local vipPick = AssetFinder.FindPickaxe("VIPPickaxe")
    local vipBackapck = AssetFinder.FindBackpack("VIPBackpack")
    local Shop = self.Services.Shop
    Shop:AddAsset(plr, vipPick)
    Shop:AddAsset(plr, vipBackapck)
    local hasRedeemedVipBoosts = self.Services.PlayerData:GetStore(plr, "HasRedeemedVipBoosts")
    if not hasRedeemedVipBoosts:getState() then
        for i = 1, 10, 1 do
            self.Services.Boosts:AddRandomBoost(plr, 25)
        end
        hasRedeemedVipBoosts:dispatch(
            {
                type = "Set",
                Value = true
            }
        )
    end

    local VipPetAwarded = self.Services.PlayerData:GetStore(plr, "VipPetAwarded")
    if not VipPetAwarded:getState() then
        self.Services.PetService:GivePlayerPet(plr, "CrystalRegular")
        VipPetAwarded:dispatch(
            {
                type = "Set",
                Value = true
            }
        )
    end
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
