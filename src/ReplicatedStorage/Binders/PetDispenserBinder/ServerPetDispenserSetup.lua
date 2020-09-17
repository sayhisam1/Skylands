local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local PetService = Services.PetService
local EffectsService = Services.EffectsService

return function(dispenser)
	assert(RunService:IsServer(), "Can only be called on server!")
	local nc = dispenser:GetNetworkChannel()
	dispenser._maid:GiveTask(
		nc:Subscribe(
			"TRY_BUY",
			function(plr)
				local gemStore = PlayerData:GetStore(plr, "Gems")
				local gemCost = dispenser:GetAttribute("GemCost")
				if gemStore:getState() < gemCost then
					dispenser:Log(3, plr, "failed to buy a pet! (not enough gems)")
					return
				end
				local petGenerator = require(dispenser:FindFirstChild("PetProbabilities"))
				local petToAward = petGenerator:Sample()[1]
				PetService:GivePlayerPet(plr, petToAward:GetInstance().Name)
				gemStore:dispatch(
					{
						type = "Increment",
						Amount = -1 * gemCost
					}
				)
				local petInst = petToAward:GetInstance():Clone()
				EffectsService:AddTemporarySharedInstance(petInst, 10)
				nc:PublishPlayer(plr, "BOUGHT_PET", petInst)
			end
		)
	)
end
