local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetBinder = require(ReplicatedStorage.Objects.Shared.AssetBinder)
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)

local setup = AssetSetup.new("Ores", script:GetChildren())

setup:AddSetupTask(
	function(ore)
		if not ore.PrimaryPart then
			error("Couldn't get ore primary part!")
		end
	end
)
local physics = PhysicalProperties.new(0, 0, 0, 0, 0)

setup:AddSetupTask(
	function(ore)
		for _, v in pairs(ore:GetDescendants()) do
			if v:IsA("BasePart") then
				if not v == ore.PrimaryPart then
					v.CanCollide = false
				end
				v.Massless = true
				v.CustomPhysicalProperties = physics
				v.CastShadow = false
			end
		end
	end
)

setup:AddSetupTask(
	function(ore)
		local health = ore:FindFirstChild("Health")
		if health.Value == math.huge then
			local unmineable = Instance.new("BoolValue")
			unmineable.Value = true
			unmineable.Name = "Unmineable"
			unmineable.Parent = ore
		else
			local totalHealth = Instance.new("NumberValue")
			totalHealth.Value = health.Value
			totalHealth.Name = "TotalHealth"
			totalHealth.Parent = ore
		end
	end
)

setup:AddRequiredChild(
	"DisplayName",
	function(ore)
		local stringVal = Instance.new("StringValue")
		stringVal.Value = ore.Name
		return stringVal
	end
)

local ores = AssetSetup.RecursiveFilter(script.Parent, "Model")
ores = setup:Setup(ores)

local Binder = require(script.Binder)
return AssetBinder.new(Binder, ores)
