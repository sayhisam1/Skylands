local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local ServerScriptService = game:GetService("ServerScriptService")
local CreateMeteor = require(ServerScriptService.Modules.CreateMeteor)

return function(chest)
	assert(RunService:IsServer(), "Can only be called on server!")
	local chestChannel = chest:GetNetworkChannel()
	chestChannel:Subscribe("Open", function(plr)
		chest:Log(3, plr, "Opened chest!")
		local lastChestTimeStore = PlayerData:GetStore(plr, "LastChestTime")
		local currTime = os.time()
		if currTime - lastChestTimeStore:getState() > chest:GetAttribute("OpenCooldown") then
			-- set new open time --
			lastChestTimeStore:dispatch({
				type="Set",
				Value=currTime
			})
			local meteor = CreateMeteor("Daily Reward", 1, 1000, math.ceil(math.random()*500 + 300))
			meteor:GetInstance().Parent = plr
			chestChannel:PublishPlayer(plr, "OpenClient", meteor:GetInstance())
			Debris:AddItem(meteor:GetInstance(), 60)
		end
	end)
end
