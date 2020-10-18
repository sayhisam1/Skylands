local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

return function(context, plr, storename, val)
	local PlayerData = Services.PlayerData
	local store = PlayerData:GetStore(plr, storename)
	store:dispatch(
		{
			type = "Set",
			Value = val
		}
	)
	return string.format("Set %s store %s to %d", plr.Name, storename, val)
end
