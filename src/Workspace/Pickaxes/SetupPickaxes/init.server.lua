local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)
local Welding = require(ReplicatedStorage.Utils.Welding)

local setup = AssetSetup.new("Pickaxes", script:GetChildren())

setup:AddSetupTask(
	function(pickaxe)
		local pickaxeHandle = pickaxe:FindFirstChild("PickaxeHandle")
		for _, v in pairs(pickaxeHandle:GetChildren()) do
			if v:IsA("Decal") then
				v:Destroy()
			end
		end
	end
)

setup:AddSetupTask(
	function(pickaxe)
		local parts = pickaxe:FindFirstChild("Parts")
		assert(parts and parts:IsA("Model"), "Couldn't find pickaxe parts!")
		if not parts.PrimaryPart then
			error("Couldn't find primary part!")
		end
	end
)

setup:AddSetupTask(
	function(pickaxe)
		for _, v in pairs(pickaxe:GetDescendants()) do
			if v:IsA("Motor6D") then
				v:Destroy()
			end
		end
		local pickaxeHandle = pickaxe:FindFirstChild("PickaxeHandle")
		local parts = pickaxe:FindFirstChild("Parts")
		Welding.motor6dParts(pickaxeHandle, parts.PrimaryPart)
		for _, other in pairs(parts:GetChildren()) do
			if other ~= parts.PrimaryPart and other:IsA("BasePart") then
				Welding.motor6dParts(parts.PrimaryPart, other)
			end
		end
		for _, v in pairs(pickaxe:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
				v.CanCollide = false
			end
		end
	end
)

setup:AddRequiredChild(
	"DisplayName",
	function(pickaxe)
		local stringVal = Instance.new("StringValue")
		stringVal.Value = pickaxe.Name
		return stringVal
	end
)

local pickaxes = AssetSetup.RecursiveFilter(script.Parent, "Tool")
setup:Setup(pickaxes)

script.Parent.Parent = ReplicatedStorage
script:Destroy()
