local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Services = require(ReplicatedStorage.Services)
local GuiController = Services.GuiController

local LocalPlayer = Players.LocalPlayer
local Roact = require(ReplicatedStorage.Lib.Roact)

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
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
	local nc = dispenser:GetNetworkChannel()

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
		local probabilities = require(dispenser:GetAttribute("PetProbabilities"))
		local pets = {}
		for pet, prob in pairs(probabilities:GetNormalizedProbabilities()) do
			pets[#pets + 1] = {
				Pet = pet,
				Rarity = prob * 100
			}
		end
		table.sort(pets, function(a, b)
			return a.Rarity > b.Rarity
		end)
		local gemCost = dispenser:GetAttribute("GemCost")
		local el = Roact.createElement(PetDispenserBuyGui, {
			Choices = pets,
			GemCost = gemCost,
			CloseCallback = function()
				dispenser._maid['gui'] = nil
			end,
			OpenOneCallback = function()
				nc:Publish("TRY_BUY")
			end,
			OpenThreeCallback = function()
				nc:Publish("TRY_BUY_THREE")
			end,
			Auto = function()
				nc:Publish("TRY_BUY_AUTO")
			end
		})
		local handle = Roact.mount(el, playergui)
		dispenser._maid["gui"] = function()
			Roact.unmount(handle)
		end
	end
	local function notInRange()
		if not isBound then
			return
		end
		isBound = false
		dispenser._maid["playergui"] = nil
		dispenser._maid["gui"] = nil
	end
	local dispenserRange = dispenser:GetAttribute("InteractRange")
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

	local function renderPet(pet, offset)
		local camPetPortal = CameraModel.new(Workspace.Camera, PET_PORTAL:Clone())
		local camModel = CameraModel.new(Workspace.Camera, pet)
		if dispenser._maid["playergui"] then
			dispenser._maid["playergui"].Enabled = false
		end
		dispenser:Log(3,pcall(function()
			local portalSound = camPetPortal._instance.PrimaryPart:FindFirstChild("Portal")
			camPetPortal:Render(CFrame.new(offset, 0, -5))
			portalSound:Play()
			camModel:Render(CFrame.new(offset, 0, -4) * CFrame.Angles(0, math.pi, 0))
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
	end

	local camMaid = Maid.new()
	local function setPlayerCam()
		local cameraPart = dispenser:FindFirstChild("CameraPart")
		local cam = Workspace.Camera
		local oldSubj = cam.CameraSubject
		local oldTy = cam.CameraType
		local oldCF = cam.CFrame
		camMaid:GiveTask(function()
			cam.CameraSubject = oldSubj
			cam.CameraType = oldTy
			cam.CFrame = oldCF
		end)
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CameraSubject = cameraPart
		cam.CFrame = cameraPart.CFrame
	end
	dispenser._maid:GiveTask(nc:Subscribe("BOUGHT_PET", function(pet)
		dispenser:Log(3, "BOUGHT", pet)
		setPlayerCam()
		renderPet(pet, 0)
		camMaid:Destroy()
	end))


	dispenser._maid:GiveTask(nc:Subscribe("BOUGHT_PET_THREE", function(...)
		local pets = {...}
		dispenser:Log(3, "BOUGHT", pets)
		local i = -1
		setPlayerCam()
		for _, pet in pairs(pets) do
			coroutine.wrap(function()
				renderPet(pet, i * 3)
			end)()
			i = i + 1
		end
		wait(5)
		camMaid:Destroy()
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
