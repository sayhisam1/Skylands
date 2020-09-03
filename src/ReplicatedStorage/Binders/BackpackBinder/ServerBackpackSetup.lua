local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(backpack)
	assert(RunService:IsServer(), "Can only be called on server!")
	local backpackInstance = backpack:GetInstance()
	local backpackPlayer = backpackInstance.Parent
	assert(backpackPlayer, "No player for backpack!")
	local maid = Maid.new()
	backpack._maid:GiveTask(maid)

	local capacityStore = Services.PlayerData:GetStore(backpackPlayer, "BackpackCapacity")
	local capacity = backpack:GetAttribute("Capacity") or 0
	capacityStore:dispatch(
		{
			type = "Set",
			Value = capacity
		}
	)
	maid:GiveTask(
		function()
			capacityStore:dispatch(
				{
					type = "Set",
					Value = 0
				}
			)
		end
	)
end
