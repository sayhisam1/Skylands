local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Services = require(ReplicatedStorage.Services)
local GuiController = Services.GuiController

local LocalPlayer = Players.LocalPlayer
local PetDispenserBuyGui = require(script.PetDispenserBuyGui)
local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)
local CameraModel = require(ReplicatedStorage.Objects.Shared.CameraModel)
local RescaleModel = require(ReplicatedStorage.Lib.RescaleModel)
local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local PET_PORTAL = ASSETS:WaitForChild("PetPortal")
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

	local nc = dispenser:GetNetworkChannel()
	dispenser._maid:GiveTask(nc:Subscribe("BOUGHT_PET", function(pet)
		dispenser:Log(3, "BOUGHT", pet)
		local camPetPortal = CameraModel.new(Workspace.Camera, PET_PORTAL:Clone())
		local camModel = CameraModel.new(Workspace.Camera, pet)
		if dispenser._maid["playergui"] then
			dispenser._maid["playergui"].Enabled = false
		end
		dispenser:Log(3,pcall(function()
			local portalSound = camPetPortal._instance.PrimaryPart:FindFirstChild("Portal")
			camPetPortal:Render(CFrame.new(0, 0, -5))
			portalSound:Play()
			camModel:Render(CFrame.new(0, 0, -4) * CFrame.Angles(0, math.pi, 0))
			local petRescaler = RescaleModel.ModelRescaler.new(camModel._instance)
			for i=.01,1,.02 do
				RunService.Heartbeat:Wait()
				petRescaler:Rescale(i)
			end
			GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS["Gameplay"], false)
			wait(3)
			for i=1, 0,-.02 do
				RunService.Heartbeat:Wait()
				petRescaler:Rescale(i)
			end
			GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS["Gameplay"], true)
		end))
		if dispenser._maid["playergui"] then
			dispenser._maid["playergui"].Enabled = true
		end
		camPetPortal:Destroy()
		camModel:Destroy()
	end))

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
