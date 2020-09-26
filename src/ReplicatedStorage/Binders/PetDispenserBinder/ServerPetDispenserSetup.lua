local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)
local EffectsService = Services.EffectsService

local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
return function(dispenser)
	assert(RunService:IsServer(), "Can only be called on server!")

	local nc = dispenser:GetNetworkChannel()

	dispenser._maid:GiveTask(
		nc:Subscribe(
			"TRY_BUY",
			function(plr)
				dispenser:TryPurchase(plr, 1):andThenCall(dispenser.RollPet, dispenser, plr, 1):andThen(
					function(pets)
						pets = TableUtil.map(pets, function(_, pet)
							local petInst = pet:GetInstance():Clone()
							EffectsService:AddTemporarySharedInstance(petInst, 10)
							return petInst
						end)
						nc:PublishPlayer(plr, "BOUGHT_PETS", pets)
					end
				):catch(function(err)
					dispenser:Log(3, plr, "failed with error", err.code)
					nc:PublishPlayer(plr, "ERROR", err.code)
				end)
			end
		)
	)

	dispenser._maid:GiveTask(
		nc:Subscribe(
			"TRY_BUY_THREE",
			function(plr)
				dispenser:TryPurchase(plr, 3):andThenCall(dispenser.RollPet, dispenser, plr, 3):andThen(
					function(pets)
						pets = TableUtil.map(pets, function(_, pet)
							local petInst = pet:GetInstance():Clone()
							EffectsService:AddTemporarySharedInstance(petInst, 10)
							return petInst
						end)
						nc:PublishPlayer(plr, "BOUGHT_PETS", pets)
					end
				):catch(function(err)
					dispenser:Log(3, plr, "failed with error", err.code)
					nc:PublishPlayer(plr, "ERROR", err.code)
				end)
			end
		)
	)
end
