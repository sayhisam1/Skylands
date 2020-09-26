-- loads pets --
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)
local ModelUtil = require(ReplicatedStorage.Utils.ModelUtil)

local setup = AssetSetup.new("Pets", script:GetChildren())

setup:AddSetupTask(
	function(pet)
		pet.PrimaryPart = pet.PrimaryPart or ModelUtil.GetCentermostPart(pet)
		ModelUtil.WeldTogether(pet)
	end
)

setup:AddRequiredChild(
	"DisplayName",
	function(pet)
		local stringVal = Instance.new("StringValue")
		stringVal.Value = pet.Name
		return stringVal
	end
)

setup:AddRequiredChild(
	"BorderColor",
	function(pet)
		local colorVal = Instance.new("Color3Value")
		colorVal.Value = Color3.fromRGB(255, 255, 255)
		return colorVal
	end
)

setup:AddRequiredChild(
	"GoldMultiplier",
	function(pet)
		local numVal = Instance.new("NumberValue")
		numVal.Value = 1
		return numVal
	end
)

setup:AddRequiredChild(
	"CriticalMultiplier",
	function(pet)
		local numVal = Instance.new("NumberValue")
		numVal.Value = 1
		return numVal
	end
)

setup:AddRequiredChild(
	"SpeedMultiplier",
	function(pet)
		local numVal = Instance.new("NumberValue")
		numVal.Value = 1
		return numVal
	end
)

setup:AddSetupTask(
	function(pet)
		ModelUtil.SetAnchored(pet, false)
		ModelUtil.SetCanCollide(pet, false)
	end
)

setup:AddSetupTask(
	function(pet)
		for _, v in pairs(pet:GetDescendants()) do
			if v:IsA("ParticleEffect") and v.Parent.Name:match("Portal") then
				v.Enabled = false
			end
		end
	end
)

setup:AddSetupTask(
	function(pet)
		pet.Parent = script.Parent
	end
)

setup:AddSetupTask(
	function(pet)
		CollectionService:AddTag(pet, Enums.Tags.Pet)
	end
)

local pets = AssetSetup.RecursiveFilter(script.Parent, "Model")
setup:Setup(pets)

for _, v in pairs(script.Parent:GetChildren()) do
	if v:IsA("Folder") then
		v:Destroy()
	end
end

script.Parent.Parent = ReplicatedStorage
script:Destroy()
