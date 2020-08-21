local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AttackContext = require(ReplicatedStorage.Objects.Abstract.AttackContext)
local Welding = require(ReplicatedStorage.Utils.Welding)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

return function(tool)
	assert(RunService:IsServer(), "Can only be called on server!")
	local toolInstance = tool:GetInstance()
	local pickaxeAttackContext = AttackContext.new()
	tool._maid:GiveTask(pickaxeAttackContext)
	local maid = Maid.new()
	tool._maid:GiveTask(maid)
	tool._maid:GiveTask(toolInstance.Equipped:Connect(function()
		-- Weld motor6d to hand
		local char = toolInstance.Parent
		local rightHand = char:FindFirstChild("RightHand")
		local handle = toolInstance.PickaxeHandle
		maid:GiveTask(Welding.motor6dParts(rightHand, handle, CFrame.new(0,0,-1)*CFrame.Angles(math.pi/-2, 0, 0) * CFrame.Angles(0,math.pi/2,0)))
		handle.Anchored = false

		pickaxeAttackContext:Enable()
	end))

	tool._maid:GiveTask(toolInstance.Unequipped:Connect(function()
		local handle = tool:FindFirstChild("PickaxeHandle")
		handle.Anchored = true
		maid:Destroy()
		pickaxeAttackContext:Disable()
	end))

	tool._maid:GiveTask(toolInstance.Activated:Connect(function()
		local action = tool:GetAttribute("MineAction") or script.Parent.DefaultMine
		pickaxeAttackContext:MakeAttack(require(action)(tool))
	end))
end
