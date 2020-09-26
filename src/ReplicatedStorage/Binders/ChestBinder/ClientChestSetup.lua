local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Services = require(ReplicatedStorage.Services)
local OreBinder = require(ReplicatedStorage.Binders.OreBinder)
local ClientPlayerData = Services.ClientPlayerData
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local CameraShaker = require(ReplicatedStorage.Utils.CameraShaker)
local Numerical = require(ReplicatedStorage.Utils.Numerical)

return function(chest)
	assert(RunService:IsClient(), "Can only be called on server!")
	local chestInstance = chest:GetInstance()
	local touchPart = chestInstance.PrimaryPart
	local chestChannel = chest:GetNetworkChannel()
	local lastChestTimeStore = ClientPlayerData:GetStore("LastChestTime")
	local animationController = chest:FindFirstChild("AnimationController")
	local openTrack = animationController:LoadAnimation(animationController:WaitForChild("Open"))
	local openedTrack = animationController:LoadAnimation(animationController:WaitForChild("Opened"))
	openTrack.Stopped:Connect(function()
		openedTrack:Play()
	end)
	local debounce = false
	chest._maid:GiveTask(
		touchPart.Touched:Connect(
			function(p)
				if not p:IsDescendantOf(LocalPlayer.Character) or debounce then
					return
				end
				debounce = true
				local currTime = os.time()
				if currTime - lastChestTimeStore:getState() > chest:GetAttribute("OpenCooldown") then
					chest:Log(3, "Opened chest", lastChestTimeStore:getState())
					chestChannel:Publish("Open")
				end
				wait(1)
				debounce = false
			end
		)
	)
	chestChannel:Subscribe("OpenClient", function(meteor)
		meteor.Parent = OreBinder:GetOresDirectory()
		meteor = OreBinder:BindClient(meteor)
		openTrack:Play()
		local init = Vector3.new(-101.841, 50012.066, -127.879)
		local s = init + Vector3.new(1000, 1000, 1000)
		local e = init
		local g = Vector3.new(0, -9, 0)
		local path = Numerical.BallisticMotion(s, e, g)
		for i=0,1,.01 do
			local n = path(i)
			meteor:SetCFrame(CFrame.new(n))
			wait()
		end
		meteor:SetCFrame(CFrame.new(e))
		meteor:FindFirstChild("Boom"):Play()
		local cam = Workspace.Camera
		local function shakeCam(cf)
			cam.CFrame = cam.CFrame * cf
		end
		local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, shakeCam)
		camShake:Start()
		camShake:StartShake(30, 10)
		camShake:StopSustained(1)
		wait(1)
		camShake:Stop()
		openedTrack:Stop()
	end)
	coroutine.wrap(function()
		while not chest._destroyed do
			local chestLabel = chest:FindFirstChild("ChestLabel")
			local textLabel = chestLabel and chestLabel:FindFirstChild("TextLabel")
			if textLabel then
				local t = lastChestTimeStore:getState() or 0
				local curr = os.time()
				local diff = math.max(0, chest:GetAttribute("OpenCooldown") - (curr - t))
				local min = math.max(math.floor(diff/60), 0)
				local sec = math.max(diff%60, 0)
				if min == 0 and sec == 0 then
					textLabel.Text = string.format("%s", "READY!")
				else
					textLabel.Text = string.format("%.2d:%.2d", min, sec)
				end
			end
			wait(.5)
		end
	end)()
end
