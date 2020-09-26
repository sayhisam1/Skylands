local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Services = require(ReplicatedStorage.Services)
local Enums = require(ReplicatedStorage.Enums)

local GuiController = Services.GuiController

local LocalPlayer = Players.LocalPlayer
local Roact = require(ReplicatedStorage.Lib.Roact)

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Promise = require(ReplicatedStorage.Lib.Promise)
local PetDispenserBuyGui = require(script.PetDispenserBuyGui)
local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)
local CameraModel = require(ReplicatedStorage.Objects.Shared.CameraModel)
local RescaleModel = require(ReplicatedStorage.Lib.RescaleModel)

local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local PortalSound = ASSETS:WaitForChild("PortalSound")
return function(dispenser)
	assert(RunService:IsClient(), "Can only be called on client!")
	dispenser:Log(3, "Setting up..")

	local nc = dispenser:GetNetworkChannel()
	local running = false
	local autoMode = false

	local dispenser_open_maid = Maid.new()
	dispenser._maid:GiveTask(dispenser_open_maid)
	local function makeStopAutoGui()
		local playergui = Instance.new("ScreenGui")
		playergui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		playergui.Parent = game.Players.LocalPlayer.PlayerGui
		local el =
			Roact.createElement(
			"TextButton",
			{
				Text = "Stop Auto",
				Position = UDim2.new(.5, 0, .8, 0),
				Size = UDim2.new(.3, 0, .2, 0),
				AnchorPoint = Vector2.new(.5, .5),
				BackgroundColor3 = Color3.fromRGB(255, 0, 0),
				TextScaled = true,
				Font = Enum.Font.GothamBlack,
				[Roact.Event.MouseButton1Click] = function()
					dispenser_open_maid["StopAutoGui"] = nil
					autoMode = false
				end,
				TextColor3 = Color3.new(1, 1, 1)
			}, {
				UICorner = Roact.createElement("UICorner", {
					CornerRadius = UDim.new(.1, 0)
				})
			}
		)

		local handle = Roact.mount(el, playergui)
		dispenser_open_maid["StopAutoGui"] = function()
			Roact.unmount(handle)
		end
	end
	local function try_buy(n, auto)
		if running then
			return
		end
		if auto then
			autoMode = true
			makeStopAutoGui()
		end
		if n == 1 then
			nc:Publish("TRY_BUY")
		elseif n == 3 then
			nc:Publish("TRY_BUY_THREE")
		end
	end
	local function makeGui()
		local playergui = Instance.new("ScreenGui")
		playergui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		playergui.Parent = game.Players.LocalPlayer.PlayerGui
		dispenser_open_maid["playergui"] = playergui
		local probabilities = require(dispenser:GetAttribute("PetProbabilities"))
		local pets = {}
		for pet, prob in pairs(probabilities:GetNormalizedProbabilities()) do
			pets[#pets + 1] = {
				Pet = pet,
				Rarity = prob * 100
			}
		end
		table.sort(
			pets,
			function(a, b)
				return a.Rarity > b.Rarity
			end
		)
		local gemCost = dispenser:GetAttribute("GemCost")
		local devproductId = dispenser:GetAttribute("DevproductId")
		local ticketCost = dispenser:GetAttribute("TicketCost")

		local currencyImage
		local cost
		if gemCost then
			currencyImage = "rbxassetid://5629921147"
			cost = gemCost
		elseif ticketCost then
			currencyImage = "rbxassetid://5707328166"
			cost = ticketCost
		elseif devproductId then
			cost = MarketplaceService:GetProductInfo(devproductId, "Product").PriceInRobux
			currencyImage = "rbxassetid://2572473536"
		end
		local el =
			Roact.createElement(
			PetDispenserBuyGui,
			{
				Choices = pets,
				Cost = cost,
				CurrencyImage = currencyImage,
				CloseCallback = function()
					dispenser_open_maid["gui"] = nil
				end,
				OpenOneCallback = function()
					try_buy(1, false)
				end,
				OpenThreeCallback = function()
					try_buy(3, false)
				end,
				AutoCallback = function()
					try_buy(1, true)
				end
			}
		)

		local handle = Roact.mount(el, playergui)
		dispenser_open_maid["gui"] = function()
			Roact.unmount(handle)
		end
	end
	local function bindKeys()
		ContextActionService:BindAction(
			"TRY_BUY",
			function(actionName, inputState, _)
				if actionName == "TRY_BUY" then
					if inputState == Enum.UserInputState.Begin then
						try_buy(1, false)
					end
				end
			end,
			false,
			Enum.KeyCode.E
		)
		ContextActionService:BindAction(
			"TRY_BUY_THREE",
			function(actionName, inputState, _)
				if actionName == "TRY_BUY_THREE" then
					if inputState == Enum.UserInputState.Begin then
						try_buy(3, false)
					end
				end
			end,
			false,
			Enum.KeyCode.R
		)
		ContextActionService:BindAction(
			"TRY_BUY_AUTO",
			function(actionName, inputState, _)
				if actionName == "TRY_BUY_AUTO" then
					if inputState == Enum.UserInputState.Begin then
						try_buy(1, true)
					end
				end
			end,
			false,
			Enum.KeyCode.T
		)
		dispenser_open_maid["keybinds"] = function()
			ContextActionService:UnbindAction("TRY_BUY")
			ContextActionService:UnbindAction("TRY_BUY_THREE")
			ContextActionService:UnbindAction("TRY_BUY_AUTO")
		end
	end
	local isBound = false
	local function inRange()
		if isBound then
			return
		end
		isBound = true
		autoMode = false
		makeGui()
		bindKeys()
	end
	local function notInRange()
		if not isBound then
			return
		end
		isBound = false
		autoMode = false
		dispenser_open_maid:Destroy()
	end
	local dispenserRange = dispenser:GetAttribute("InteractRange")
	GetPrimaryPart(dispenser:GetInstance()):andThen(
		function(primary_part)
			local function hookLoop()
				GetPlayerCharacterWorkspace(LocalPlayer):andThen(
					function(character)
						GetPrimaryPart(character):andThen(
							function(char_primary)
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
							end
						)
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
		local renderMaid = Maid.new()
		dispenser_open_maid:GiveTask(renderMaid)
		renderMaid:GiveTask(pet)
		return Promise.new(
			function(resolve, reject, onCancel)
				if dispenser_open_maid["playergui"] then
					dispenser_open_maid["playergui"].Enabled = false
					renderMaid:GiveTask(
						function()
							if dispenser_open_maid["playergui"] then
								dispenser_open_maid["playergui"].Enabled = true
							end
						end
					)
				end
				-- HACK: enable portal effects on pet
				for _, v in pairs(pet:GetDescendants()) do
					if v:IsA("ParticleEffect") and v.Parent.Name:match("Portal") then
						v.Enabled = true
					end
				end
				local portalSound = PortalSound
				portalSound:Play()
				local camModel = CameraModel.new(Workspace.Camera, pet)
				renderMaid:GiveTask(camModel)
				camModel:Render(CFrame.new(offset, 0, -7) * CFrame.Angles(0, math.pi, 0))
				local petRescaler = RescaleModel.ModelRescaler.new(camModel._instance)
				for i = .01, 1, .02 do
					RunService.Heartbeat:Wait()
					petRescaler:Rescale(i)
				end
				GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS["Gameplay"], false)
				renderMaid:GiveTask(
					function()
						GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS["Gameplay"], true)
					end
				)
				wait(2)
				for i = 1, 0, -.02 do
					RunService.Heartbeat:Wait()
					petRescaler:Rescale(i)
				end
				resolve()
			end
		):finally(
			function()
				renderMaid:Destroy()
			end
		)
	end

	local function setPlayerCam()
		local camMaid = Maid.new()
		dispenser_open_maid["set_cam"] = camMaid
		local cameraPart = dispenser:FindFirstChild("CameraPart")
		local cam = Workspace.Camera
		local oldCF = cam.CFrame
		camMaid:GiveTask(
			function()
				cam.CameraSubject = game.Players.LocalPlayer.Character.Humanoid
				cam.CameraType = Enum.CameraType.Custom
				cam.CFrame = oldCF
			end
		)
		cam.CameraType = Enum.CameraType.Scriptable
		cam.CameraSubject = cameraPart
		cam.CFrame = cameraPart.CFrame
		return camMaid
	end

	dispenser._maid:GiveTask(
		nc:Subscribe(
			"BOUGHT_PETS",
			function(pets)
				local i_offset = -1
				if #pets > 1 then
					i_offset = -2
				end
				dispenser:Log(3, "BOUGHT", pets)
				running = true
				local camMaid = setPlayerCam()
				local petRenders = {}
				for i, pet in pairs(pets) do
					petRenders[i] = renderPet(pet, (i + i_offset) * 3)
				end
				Promise.all(petRenders):finally(
					function()
						camMaid:Destroy()
						running = false
						if autoMode then
							try_buy(1)
						end
					end
				)
			end
		)
	)

	dispenser._maid:GiveTask(
		nc:Subscribe(
			"ERROR",
			function(code)
				autoMode = false
				dispenser_open_maid["StopAutoGui"] = nil
				if code == Enums.Errors.NotEnoughGems then
					GuiController:PromptOutOfGems()
				elseif code == Enums.Errors.NotEnoughPetSlots then
					GuiController:PromptPetInventoryFull()
				end
			end
		)
	)
	dispenser._maid:GiveTask(
		function()
			notInRange()
		end
	)
end
