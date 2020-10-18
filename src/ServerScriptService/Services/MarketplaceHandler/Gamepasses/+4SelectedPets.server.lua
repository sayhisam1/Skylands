local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData

local gamepassId = 11928461

local function setupPlayer(plr)
    local HasRedeemedSelectedPetsGamepassStore = PlayerData:GetStore(plr, "HasRedeemedSelectedPetsGamepass")
    if not HasRedeemedSelectedPetsGamepassStore:getState() then
        local MaxSelectedPets = PlayerData:GetStore(plr, "MaxSelectedPets")
        MaxSelectedPets:dispatch(
            {
                type = "Increment",
                Amount = 4
            }
        )
        HasRedeemedSelectedPetsGamepassStore:dispatch(
            {
                type = "Set",
                Value = true
            }
        )
    end
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
