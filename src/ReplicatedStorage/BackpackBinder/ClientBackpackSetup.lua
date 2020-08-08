local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(backpack)
	assert(RunService:IsClient(), "Can only be called on client!")
	local backpackInstance = backpack:GetInstance()
	local player = backpackInstance.Parent
	assert(player and player:IsA("Player"), "No player for backapck!")
	local maid = Maid.new()
	backpack._maid:GiveTask(maid)

	local welding = backpack:GetAttribute("BackpackWeld") or script.Parent.BackpackWeld
	wait(1)
	require(welding)(backpack)
	backpackInstance.Parent = player.Character
	maid:GiveTask(backpackInstance)
end
