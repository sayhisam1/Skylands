--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"AssetManager"}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

local Maid = require("Maid").new()
local Services = _G.Services

local PlayerGui = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
local StarterGui = game:GetService("StarterGui")
-- local MainGui = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("MainGui"):Clone()
-- MainGui.Parent = PlayerGui
-- MainGui.Enabled = true
--local GuiModule = require(MainGui:WaitForChild("GuiModule"))
local ADMINS = {41283451, 5359610, 90341494}
--local GuiModule = require(MainGui:WaitForChild("GuiModule"))

function Service:Load()
	--while not GuiModule do wait() end

	-- Load client sided cmdr gui (lol don't even try exploiting this - everything is verified on server)
	for _, id in pairs(ADMINS) do
		if game.Players.LocalPlayer.UserId == id then
			local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
			Cmdr:SetActivationKeys({Enum.KeyCode.Semicolon})
		end
	end

	PlayerGui.ChildAdded:Connect(function(child)
		if child:IsA("ScreenGui") and child:FindFirstChild("Main") then
			local m = require(child:FindFirstChild("Main"))
			m:Start()
		end
	end)
end

function Service:Unload()
end

function Service:SetViewportModel(viewport, model)
	model:SetPrimaryPartCFrame(CFrame.new(0,0,0))
	model.Parent = viewport
	local newCam = Instance.new("Camera")
	viewport.CurrentCamera = newCam
	newCam.CFrame = CFrame.new(Vector3.new(0,0,-10), model.PrimaryPart.Position)
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") and v.Transparency > 0 then
			v.Transparency = .9
		end
	end
	return viewport
end

-- Returns a copy of the gui from replicatedstorage
function Service:GetGui(gui_name)
	local asset_folder = _G.Services.AssetManager:GetAssetFolder()
	local gui_folder = asset_folder:FindFirstChild("Gui")
	return gui_folder:FindFirstChild(gui_name):Clone()
end
return Service
