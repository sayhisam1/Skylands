local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local ClientPlayerData = Services.ClientPlayerData
local GuiController = Services.GuiController

local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)

local AttackContext = require(ReplicatedStorage.Objects.Abstract.AttackContext)
local MiningUtil = require(ReplicatedStorage.Utils.MiningUtil)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(tool)
	assert(RunService:IsClient(), "Can only be called on client!")
	local toolInstance = tool:GetInstance()
	local pickaxeAttackContext = AttackContext.new()
	tool._maid:GiveTask(pickaxeAttackContext)
	local maid = Maid.new()
	tool._maid:GiveTask(maid)
	tool._maid:GiveTask(
		toolInstance.Equipped:Connect(
			function()
				local BlockIndicatorRender = GuiController:GetBlockIndicatorRender()

				local character = toolInstance.Parent
				if character ~= game.Players.LocalPlayer.Character then
					return
				end
				local SelectionBox = Instance.new("SelectionBox")
				SelectionBox.Parent = tool:GetInstance()
				maid:GiveTask(SelectionBox)

				local range = tool:GetAttribute("Range")
				maid:GiveTask(
					RunService.Heartbeat:Connect(
						function()
							local ore = MiningUtil.GetTargetOre(character.PrimaryPart.Position, range)
							if ore and ore:IsMineable() then
								SelectionBox.Adornee = ore:GetInstance().PrimaryPart
								local name = ore:GetAttribute("DisplayName")
								local nameColor = ore:GetAttribute("TextColor")

								local health = ore:GetAttribute("Health")
								local totalHealth = ore:GetAttribute("TotalHealth")
								local goldValue = ore:GetAttribute("Value") or 0
								goldValue = goldValue * Multipliers.GetMultiplier("Gold")

								local gemValue = ore:GetAttribute("GemValue") or 0
								gemValue = gemValue * Multipliers.GetMultiplier("Gems")
								BlockIndicatorRender(name, nameColor, health, totalHealth, goldValue, gemValue)
							else
								SelectionBox.Adornee = nil
								BlockIndicatorRender()
							end
						end
					)
				)

				maid:GiveTask(
					UserInputService.InputBegan:Connect(
						function(input, gameProcessedEvent)
							if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
								toolInstance:Activate()
							end
						end
					)
				)
				maid:GiveTask(
					UserInputService.TouchTapInWorld:Connect(
						function(_, processedByUI)
							if not processedByUI then
								toolInstance:Activate()
							end
						end
					)
				)
				local humanoid = character:FindFirstChildWhichIsA("Humanoid")
				local idle_anim_track = humanoid:LoadAnimation(tool:FindFirstChild("IdleAnimation"))
				idle_anim_track:Play()

				maid:GiveTask(
					function()
						idle_anim_track:Stop()
					end
				)

				pickaxeAttackContext:Enable()
			end
		)
	)

	tool._maid:GiveTask(
		toolInstance.Unequipped:Connect(
			function()
				local BlockIndicatorRender = GuiController:GetBlockIndicatorRender()
				pickaxeAttackContext:Disable()
				BlockIndicatorRender()
				maid:Destroy()
			end
		)
	)

	tool._maid:GiveTask(
		toolInstance.Activated:Connect(
			function()
				local backpackCapacity = ClientPlayerData:GetStore("BackpackCapacity"):getState()
				local plrOreCount = ClientPlayerData:GetStore("OreCount"):getState()
				if plrOreCount >= backpackCapacity then
					GuiController:PromptBackpackFull()
					return
				end
				local character = toolInstance.Parent
				if character ~= game.Players.LocalPlayer.Character then
					return
				end
				local action = tool:GetAttribute("MineAction") or script.Parent.DefaultMine
				action = require(action)(tool)
				if pickaxeAttackContext:CanMakeAttack(action) then
					action.Stopped:Connect(function()
						if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
							RunService.Heartbeat:Wait()
							toolInstance:Activate()
						end
					end)
					pickaxeAttackContext:MakeAttack(action)
				end
			end
		)
	)
end
