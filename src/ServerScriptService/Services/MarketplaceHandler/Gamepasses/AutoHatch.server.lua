local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData

local gamepassId = 11685523

local function setupPlayer(plr)
    local IsAutoHatchEnabledStore = PlayerData:GetStore(plr, "IsAutoHatchEnabled")
    IsAutoHatchEnabledStore:dispatch({
        type="Set",
        Value=true,
    })
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
