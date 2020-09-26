local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)
local PET_MULTIPLIER_LIST = {"Gold", "Speed", "Critical"}
return function(pet)
	assert(RunService:IsServer(), "Can only be called on server!")
	local petInstance = pet:GetInstance()
	local petPlayer = petInstance.Parent
	assert(petPlayer, "No player for pet!")
	local maid = Maid.new()
	pet._maid:GiveTask(maid)
	for _, m in pairs(PET_MULTIPLIER_LIST) do
		local mult = pet:GetAttribute(string.format("%sMultiplier", m))
		if mult then
			maid:GiveTask(Multipliers.AddPlayerMultiplier(petPlayer, m, mult))
		end
	end
	-- pet:SetupAbilities(petPlayer)
end
