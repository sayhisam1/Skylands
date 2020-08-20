local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)

return function(pet)
	assert(RunService:IsServer(), "Can only be called on server!")
	local petInstance = pet:GetInstance()
	local petPlayer = petInstance.Parent
	assert(petPlayer, "No player for pet!")
	local maid = Maid.new()
	pet._maid:GiveTask(maid)
	local goldMultiplier = pet:GetAttribute("GoldMultiplier")
	if goldMultiplier then
		maid:GiveTask(Multipliers.AddPlayerMultiplier(petPlayer, "Gold", goldMultiplier))
	end
end
