local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local PetService = Services.PetService
return function (context, plr, pet)
	PetService:GivePlayerPet(plr, pet.Name)
end