local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData

local gamepassId = 11685511

local function setupPlayer(plr)
    local HasRedeemedSlotsGamepassStore = PlayerData:GetStore(plr, "HasRedeemedSlotsGamepass")
    if not HasRedeemedSlotsGamepassStore:getState() then
        local MaxPetStorageSlots = PlayerData:GetStore(plr, "MaxPetStorageSlots")
        MaxPetStorageSlots:dispatch(
            {
                type = "Increment",
                Amount = 12
            }
        )
        HasRedeemedSlotsGamepassStore:dispatch(
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
