local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local DataDump = require(ReplicatedStorage.Utils.DataDump)
return function(context, plr, storename, val)
	local PlayerData = Services.PlayerData
	local store = PlayerData:GetStore(plr, storename)
	local output = store:getState()
	if type(output) == 'table' then
		output = DataDump.dd(output)
	end
	return output
end
