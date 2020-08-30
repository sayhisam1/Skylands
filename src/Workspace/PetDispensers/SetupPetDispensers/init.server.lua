local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)
local ModelUtil = require(ReplicatedStorage.Utils.ModelUtil)

local setup = AssetSetup.new("PetDispensers", script:GetChildren())

setup:AddSetupTask(
	function(dispenser)
		if not dispenser.PrimaryPart then
			dispenser.PrimaryPart = ModelUtil.GetCentermostPart(dispenser)
		end
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
	function(dispenser)
		if not dispenser:FindFirstChild("GemCost") then
			error("No GemCost found!")
		end
		if not dispenser:FindFirstChild("PetProbabilities") then
			error("No PetProbabilities found!")
		end
	end
)
setup:AddSetupTask(
	function(dispenser)
		CollectionService:AddTag(dispenser, Enums.Tags.PetDispenser)
	end
)

local petDispensers = AssetSetup.RecursiveFilter(script.Parent, "Model")
setup:Setup(petDispensers)

script:Destroy()