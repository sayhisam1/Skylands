local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local Map = Services.Map

return function(context)
	Map:ReloadQuarry()
	return "Reset Quarry"
end
