-- loads pets --
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)
local AssetSetup = require(ReplicatedStorage.Objects.AssetSetup)

local setup = AssetSetup.new("Titles", script:GetChildren())

setup:AddSetupTask(
	function(title)
		local gui = title:FindFirstChildWhichIsA("BillboardGui")
		assert(gui, "Couldn't find a billboard gui!")
		CollectionService:AddTag(gui, Enums.Tags.Title)
	end
)

setup:AddSetupTask(
	function(title)
		assert(title:FindFirstChild("TotalOresMined"), "Couldn't find TotalOresMined")
	end
)

local titles = AssetSetup.RecursiveFilterIgnoreRoot(script.Parent, "Folder")
setup:Setup(titles)

local dummies = AssetSetup.RecursiveFilter(script.Parent, "Model")
for _, v in pairs(dummies) do
	v:Destroy()
end

script.Parent.Parent = ReplicatedStorage
script:Destroy()
