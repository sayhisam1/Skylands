-- loads backpacks --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)

local setup = AssetSetup.new("Backpacks", script:GetChildren())

setup:AddSetupTask(function(backpack)
	if not backpack.PrimaryPart then
		error("Couldn't get backpack primary part!")
	end
end)

setup:AddRequiredChild("DisplayName", function(backpack)
	local stringVal = Instance.new("StringValue")
	stringVal.Value = backpack.Name
	return stringVal
end)

local backpacks = AssetSetup.RecursiveFilter(script.Parent, "Model")
setup:Setup(backpacks)

script.Parent.Parent = ReplicatedStorage
script:Destroy()
