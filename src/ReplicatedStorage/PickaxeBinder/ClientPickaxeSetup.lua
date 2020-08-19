local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
	tool._maid:GiveTask(toolInstance.Equipped:Connect(function()
		local character = toolInstance.Parent
		if character ~= game.Players.LocalPlayer.Character then
			return
		end
		local SelectionBox = Instance.new("SelectionBox")
		SelectionBox.Parent = tool:GetInstance()
		maid:GiveTask(SelectionBox)

		local range = tool:GetAttribute("Range")
		maid:GiveTask(RunService.Heartbeat:Connect(function()
			local ore = MiningUtil.GetTargetOre(character.PrimaryPart.Position, range)
			if ore and ore:IsMineable() then
				SelectionBox.Adornee = ore:GetInstance().PrimaryPart
			else
				SelectionBox.Adornee = nil
			end
		end))

		maid:GiveTask(
			UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
				if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not gameProcessedEvent then
					while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
						toolInstance:Activate()
						wait(.2)
					end
				end
			end)
		)
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		local idle_anim_track = humanoid:LoadAnimation(tool:FindFirstChild("IdleAnimation"))
		idle_anim_track:Play()

		maid:GiveTask(function()
			idle_anim_track:Stop()
		end)

		pickaxeAttackContext:Enable()
	end))

	tool._maid:GiveTask(toolInstance.Unequipped:Connect(function()
		pickaxeAttackContext:Disable()
		maid:Destroy()
	end))

	tool._maid:GiveTask(toolInstance.Activated:Connect(function()
		local character = toolInstance.Parent
		if character ~= game.Players.LocalPlayer.Character then
			return
		end
		local action = tool:GetAttribute("MineAction") or script.Parent.DefaultMine
		pickaxeAttackContext:MakeAttack(require(action)(tool))
	end))
end
