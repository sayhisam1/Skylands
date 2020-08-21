local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)
local WaitforInstanceDescendantOf = require(ReplicatedStorage.Objects.Promises.WaitforInstanceDescendantOf)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)

return function(pet)
	assert(RunService:IsClient(), "Can only be called on client!")
	pet:Log(3, "SETTING UP PET")
	local promise = WaitforInstanceDescendantOf(pet:GetInstance(), Players):andThen(
		function(petInstance)
			return GetPrimaryPart(petInstance)
		end
	):andThen(
		function()
			local plr = pet:GetInstance().Parent
			return GetPlayerCharacterWorkspace(plr)
		end
	):andThen(
		function(character)
			local welding = pet:GetAttribute("PetWeld") or script.Parent.PetWeld
			require(welding)(pet, character)
		end
	)

	pet._maid:GiveTask(
		function()
			promise:cancel()
		end
	)
end
