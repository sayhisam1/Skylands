-- loads ores --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)

local ORE_MODULES_DIR = Instance.new("Folder")
ORE_MODULES_DIR.Name = "_ORE_MODULES"
ORE_MODULES_DIR.Parent = ReplicatedStorage

local function createRef(instance)
	local objectValue = Instance.new("ObjectValue")
	objectValue.Value = instance
	objectValue.Name = instance.Name
	return objectValue
end
for _, v in pairs(script:GetChildren()) do
	if v:IsA("ModuleScript") then
		local req = require(v)
		if req.SetupHooks then
			req:SetupHooks()
		end
		local ref = createRef(v)
		v.Parent = ORE_MODULES_DIR
		ref.Parent = script
	end
end

local setup = AssetSetup.new("Ores", script:GetChildren())

setup:AddSetupTask(
	function(ore)
		if not ore.PrimaryPart then
			error("Couldn't get ore primary part!")
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

setup:AddSetupTask(
	function(ore)
		for _, child in pairs(ore:GetChildren()) do
			if child:IsA("ModuleScript") then
				local req = require(child)
				if req.SetupHooks then
					req:SetupHooks()
				end
				local ref = createRef(child)
				child.Parent = ORE_MODULES_DIR
				ref.Parent = ore
			end
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
setup:Setup(ores)

script.Parent.Parent = ReplicatedStorage
script:Destroy()
