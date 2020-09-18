local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local PetService = Services.PetService
local EffectsService = Services.EffectsService

return function(dispenser)
	assert(RunService:IsServer(), "Can only be called on server!")

	local nc = dispenser:GetNetworkChannel()

	local function buy(plr)
		local gemStore = PlayerData:GetStore(plr, "Gems")
		local gemCost = dispenser:GetAttribute("GemCost")
		if gemStore:getState() < gemCost then
			dispenser:Log(3, plr, "failed to buy a pet! (not enough gems)")
			return
		end
		local petGenerator = require(dispenser:FindFirstChild("PetProbabilities"))
		local petToAward = petGenerator:Sample()[1]

		local res,
			err =
			pcall(
			function()
				PetService:GivePlayerPet(plr, petToAward:GetInstance().Name)
			end
		)
		if not res then
			dispenser:Log(3, plr, "Failed to buy a pet! (", err, ")")
			return
		end
		gemStore:dispatch(
			{
				type = "Increment",
				Amount = -1 * gemCost
			}
		)
		return petToAward
	end
	dispenser._maid:GiveTask(
		nc:Subscribe(
			"TRY_BUY",
			function(plr)
				local petToAward = buy(plr)
				local petInst = petToAward:GetInstance():Clone()
				EffectsService:AddTemporarySharedInstance(petInst, 10)
				nc:PublishPlayer(plr, "BOUGHT_PET", petInst)
			end
		)
	)

	dispenser._maid:GiveTask(
		nc:Subscribe(
			"TRY_BUY_THREE",
			function(plr)
				local gemStore = PlayerData:GetStore(plr, "Gems")
				local gemCost = dispenser:GetAttribute("GemCost") * 3
				dispenser:Log(3, plr, "Buy three")
				if gemStore:getState() < gemCost then
					dispenser:Log(3, plr, "failed to buy a pet! (not enough gems)")
					return
				end

				local petInstances = {}
				for _ = 1, 3 do
					pcall(function()
						local petToAward = buy(plr)
						local petInst = petToAward:GetInstance():Clone()
						EffectsService:AddTemporarySharedInstance(petInst, 10)
						petInstances[#petInstances + 1] = petInst
						dispenser:Log(3, "Buy pet", petInst)
					end)
				end

				nc:PublishPlayer(plr, "BOUGHT_PET_THREE", unpack(petInstances))
			end
		)
	)
end
