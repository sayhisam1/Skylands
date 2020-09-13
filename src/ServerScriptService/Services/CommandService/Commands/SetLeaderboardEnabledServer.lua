local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

return function(context, plr, val)
	local PlayerData = Services.PlayerData
	local store = PlayerData:GetStore(plr, "LeaderboardHidden")
	store:dispatch({
		type="Set",
		Value=val
	})
	return string.format("Set %s store LeaderboardHidden to %s", plr.Name, tostring(val))
end
