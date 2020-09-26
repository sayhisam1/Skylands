-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local Backpacks = ReplicatedStorage:WaitForChild("Backpacks"):GetChildren()
local Pickaxes = ReplicatedStorage:WaitForChild("Pickaxes"):GetChildren()
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

function Service:Load()
    local maid = self._maid

    local network_channel = self:GetNetworkChannel()

    local function loadShop(shop_part)
        maid:GiveTask(
            shop_part.Touched:Connect(
                function(part)
                    if part.Parent:FindFirstChild("Humanoid") then
                        local plr = Players:GetPlayerFromCharacter(part.Parent)
                        if plr then
                            if self:SellBackpack(plr) then
                                network_channel:PublishPlayer(plr, "COIN_RAIN")
                            end
                        end
                    end
                end
            )
        )
    end

    self._maid:GiveTask(
        CollectionService:GetInstanceAddedSignal(self.Enums.Tags.SellPart):Connect(
            function(part)
                loadShop(part)
            end
        )
    )

    for _, part in pairs(CollectionService:GetTagged(self.Enums.Tags.SellPart)) do
        loadShop(part)
    end

    maid:GiveTask(
        network_channel:Subscribe(
            "REQUEST_SHOP_TELEPORT",
            function(plr)
                plr.Character:SetPrimaryPartCFrame(CollectionService:GetTagged(self.Enums.Tags.SellPart)[1].CFrame + Vector3.new(0, 5, 0))
            end
        )
    )

    maid:GiveTask(
        network_channel:Subscribe(
            "REQUEST_BUY",
            function(plr, instance)
                self:BuyAsset(plr, instance)
            end
        )
    )

    maid:GiveTask(
        network_channel:Subscribe(
            "REQUEST_SELECT",
            function(plr, instance)
                self:SelectAsset(plr, instance)
            end
        )
    )
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:SellBackpack(plr)
    local totalBackpackValue = self.Services.PlayerData:GetStore(plr, "BackpackGoldValue")
    local plrGold = self.Services.PlayerData:GetStore(plr, "Gold")
    local plrBackpackSlots = self.Services.PlayerData:GetStore(plr, "OreCount")
    if plrBackpackSlots:getState() == 0 then
        return
    end
    plrGold:dispatch(
        {
            type = "Increment",
            Amount = math.ceil(totalBackpackValue:getState())
        }
    )
    totalBackpackValue:dispatch(
        {
            type = "Set",
            Value = 0
        }
    )
    plrBackpackSlots:dispatch(
        {
            type = "Set",
            Value = 0
        }
    )
    return true
end
function Service:_identifyAssetType(instance)
    for _, v in pairs(Backpacks) do
        if v == instance then
            return self.Enums.Tags.Backpack
        end
    end
    for _, v in pairs(Pickaxes) do
        if v == instance then
            return self.Enums.Tags.Pickaxe
        end
    end
    error(string.format("Invalid asset: %s", instance))
end

function Service:BuyAsset(plr, instance)
    local asset_type = self:_identifyAssetType(instance)
    local goldStore = self.Services.PlayerData:GetStore(plr, "Gold")
    local assetGoldValue = instance:FindFirstChild("GoldCost", true).Value
    if assetGoldValue ~= math.huge and assetGoldValue >= 0 and goldStore:getState() >= assetGoldValue then
        -- can buy asset
        local owned_asset_list = nil
        if asset_type == self.Enums.Tags.Backpack then
            owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedBackpacks")
        elseif asset_type == self.Enums.Tags.Pickaxe then
            owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedPickaxes")
        end
        if not self.TableUtil.contains(owned_asset_list:getState(), instance.Name) then
            self:Log(3, "BUYING", instance, "FOR", assetGoldValue)
            goldStore:dispatch(
                {
                    type = "Increment",
                    Amount = -1 * assetGoldValue
                }
            )
            self:AddAsset(plr, instance)
            self:SelectAsset(plr, instance)
        end
    end
end

function Service:AddAsset(plr, instance)
    local asset_type = self:_identifyAssetType(instance)
    -- can buy asset
    local owned_asset_list = nil
    if asset_type == self.Enums.Tags.Backpack then
        owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedBackpacks")
    elseif asset_type == self.Enums.Tags.Pickaxe then
        owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedPickaxes")
    end
    owned_asset_list:dispatch(
        {
            type = "AddItem",
            Item = instance.Name
        }
    )
end

function Service:SelectAsset(plr, instance)
    local asset_type = self:_identifyAssetType(instance)
    local owned_asset_list = nil
    local selected_asset_list = nil
    if asset_type == self.Enums.Tags.Backpack then
        owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedBackpacks")
        selected_asset_list = self.Services.PlayerData:GetStore(plr, "SelectedBackpack")
    elseif asset_type == self.Enums.Tags.Pickaxe then
        owned_asset_list = self.Services.PlayerData:GetStore(plr, "OwnedPickaxes")
        selected_asset_list = self.Services.PlayerData:GetStore(plr, "SelectedPickaxe")
    end
    if self.TableUtil.contains(owned_asset_list:getState(), instance.Name) then
        self:Log(3, plr, "SELECTING", instance)
        selected_asset_list:dispatch(
            {
                type = "Set",
                Value = instance.Name
            }
        )
    end
end

return Service
