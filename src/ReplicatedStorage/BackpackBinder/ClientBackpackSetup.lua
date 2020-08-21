local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)
local WaitforInstanceDescendantOf = require(ReplicatedStorage.Objects.Promises.WaitforInstanceDescendantOf)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)

return function(backpack)
	assert(RunService:IsClient(), "Can only be called on client!")
	backpack:Log(3, "SETTING UP PET")
	local promise = WaitforInstanceDescendantOf(backpack:GetInstance(), Players):andThen(
		function(backpackInstance)
			return GetPrimaryPart(backpackInstance)
		end
	):andThen(
		function()
			local plr = backpack:GetInstance().Parent
			return GetPlayerCharacterWorkspace(plr)
		end
	):andThen(
		function(character)
			local welding = backpack:GetAttribute("BackpackWeld") or script.Parent.BackpackWeld
			require(welding)(backpack, character)
		end
	)

	backpack._maid:GiveTask(
		function()
			promise:cancel()
		end
	)
end
