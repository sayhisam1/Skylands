local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local Shop = Services.Shop
local gamepassId = 11713014

local function setupPlayer(plr)
    Services.MarketplaceHandler:Log(3, "Setup player", plr, "AutoSell!")
    local backpackGoldValue = PlayerData:GetStore(plr, "BackpackGoldValue")
    backpackGoldValue.changed:connect(
        function()
            Shop:SellBackpack(plr)
        end
    )
end

Players.PlayerAdded:Connect(
    function(plr)
        local hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
        if hasPass then
            setupPlayer(plr)
        end
    end
)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(
    function(player, purchasedPassID, purchaseSuccess)
        if purchaseSuccess == true and purchasedPassID == gamepassId then
            setupPlayer(player)
        end
    end
)
