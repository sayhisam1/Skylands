local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local Shop = Services.Shop

return function(context, plr, backpack)
	Shop:AddAsset(plr, backpack)
end
