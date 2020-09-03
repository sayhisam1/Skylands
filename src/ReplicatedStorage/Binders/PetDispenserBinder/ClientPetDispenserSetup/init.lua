local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PetDispenserBuyGui = require(script.PetDispenserBuyGui)
local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)

return function(dispenser)
	assert(RunService:IsClient(), "Can only be called on client!")
	dispenser:Log(3, "Setting up..")
	local dispenserRange = dispenser:GetAttribute("InteractRange")
	local isBound = false
	local function inRange()
		if isBound then
			return
		end
		isBound = true
		local playergui = Instance.new("ScreenGui")
		playergui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		playergui.Parent = game.Players.LocalPlayer.PlayerGui
		dispenser._maid["playergui"] = playergui
		dispenser._maid["gui"] = PetDispenserBuyGui(playergui, dispenser)
	end
	local function notInRange()
		if not isBound then
			return
		end
		isBound = false
		dispenser._maid["playergui"] = nil
		dispenser._maid["gui"] = nil
	end
	local promise =
		GetPrimaryPart(dispenser:GetInstance()):andThen(
		function(primary_part)
			local function hookLoop()
				GetPlayerCharacterWorkspace(LocalPlayer):andThen(
					function(character)
						GetPrimaryPart(character):andThen(function(char_primary)
							dispenser._maid["Character"] =
								RunService.Heartbeat:Connect(
								function()
									local dist = (primary_part.Position - char_primary.Position).Magnitude
									if dist <= dispenserRange then
										inRange()
									else
										notInRange()
									end
								end
							)
						end)
					end
				)
			end
			LocalPlayer.CharacterAdded:Connect(
				function()
					hookLoop()
				end
			)
			hookLoop()
		end
	)

	dispenser._maid:GiveTask(
		function()
			promise:cancel()
		end
	)
	dispenser._maid:GiveTask(
		function()
			notInRange()
		end
	)
end
