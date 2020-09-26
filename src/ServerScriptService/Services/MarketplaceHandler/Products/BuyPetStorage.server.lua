local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local MarketplaceHandler = Services.MarketplaceHandler
local PlayerData = Services.PlayerData

local productId = 1087600055

MarketplaceHandler:RegisterHandler(productId, function(plr)
    local MaxPetStorageSlots = PlayerData:GetStore(plr, "MaxPetStorageSlots")
    MaxPetStorageSlots:dispatch({
        type="Increment",
        Amount = 24
    })
end)
