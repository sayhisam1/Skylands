local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(pet)
	assert(RunService:IsClient(), "Can only be called on client!")
	local petInstance = pet:GetInstance()
	if not petInstance then
		return
	end
	local player = petInstance.Parent
	if not player and player:IsA("Player") then
		return
	end
	local maid = Maid.new()
	pet._maid:GiveTask(maid)

	local welding = pet:GetAttribute("PetWeld") or script.Parent.PetWeld
	wait(.1)
	require(welding)(pet)
	petInstance.Parent = player.Character
	maid:GiveTask(petInstance)
end
