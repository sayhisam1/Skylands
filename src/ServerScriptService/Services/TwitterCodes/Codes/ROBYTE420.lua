local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData

return function(plr)
    local goldStore = PlayerData:GetStore(plr, "Gold")
    goldStore:dispatch(
        {
            type = "Increment",
            Amount = 1E3
        }
    )
    return "Redeemed! Added 1000 Gold!"
end
