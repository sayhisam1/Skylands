local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local Promise = require(ReplicatedStorage.Lib.Promise)
local AssetFinder = require(ReplicatedStorage.AssetFinder)

local gamepassId = 11685532
local INFINITE_BACKPACK = AssetFinder.FindBackpack("Infinity Pack")

local function setupPlayer(plr)
    local Shop = Services.Shop
    Shop:AddAsset(plr, INFINITE_BACKPACK)
end

Players.PlayerAdded:Connect(function(plr)
	local hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
	if hasPass then
        setupPlayer(plr)
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess == true and purchasedPassID == gamepassId then
        setupPlayer(player)
	end
end)

PlayerData:RegisterResetHook("OwnedBackpacks", function(plr, store, prev)
    local ownsGamepass = Promise.new(function(resolve, reject, onCancel)
        return resolve(MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId))
    end):andThen(function()
        setupPlayer(plr)
    end)
end)

PlayerData:RegisterResetHook("SelectedBackpack", function(plr, store, prev)
    local ownsGamepass = Promise.new(function(resolve, reject, onCancel)
        return resolve(MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId))
    end):andThen(function()
        if prev == "Infinity Pack" then
            store:dispatch({
                type="Set",
                Value = "Infinity Pack"
            })
        end
    end)
end)
