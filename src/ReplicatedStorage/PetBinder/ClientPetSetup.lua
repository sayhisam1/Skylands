local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(pet)
	assert(RunService:IsClient(), "Can only be called on client!")
	local petInstance = pet:GetInstance()
	local player = petInstance.Parent
	assert(player and player:IsA("Player"), "No player for backapck!")
	local maid = Maid.new()
	pet._maid:GiveTask(maid)

	local welding = pet:GetAttribute("PetWeld") or script.Parent.PetWeld
	wait(1)
	require(welding)(pet)
	petInstance.Parent = player.Character
	maid:GiveTask(petInstance)
end
