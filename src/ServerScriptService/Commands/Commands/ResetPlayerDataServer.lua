local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData

local BLOCK_SIZE = 7
return function(context, player)
	PlayerData:ResetPlayerData(player)

	return string.format("Reset data for %s; Oof!", player.Name)
end
