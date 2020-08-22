-- loads pets --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)
local ModelUtil = require(ReplicatedStorage.Utils.ModelUtil)

local setup = AssetSetup.new("Pets", script:GetChildren())

setup:AddSetupTask(
	function(pet)
		pet.PrimaryPart = pet.PrimaryPart or ModelUtil.AutosetPrimaryPart(pet)
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

setup:AddSetupTask(
	function(pet)
		ModelUtil.SetAnchored(pet, false)
		ModelUtil.SetCanCollide(pet, false)
	end
)

setup:AddSetupTask(
	function(pet)
		pet.Parent = script.Parent
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
