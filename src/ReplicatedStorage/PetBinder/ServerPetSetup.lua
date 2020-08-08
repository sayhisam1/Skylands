local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(pet)
	assert(RunService:IsServer(), "Can only be called on server!")
	local petInstance = pet:GetInstance()
	local petPlayer = petInstance.Parent
	assert(petPlayer, "No player for pet!")
	local maid = Maid.new()
	pet._maid:GiveTask(maid)
end
