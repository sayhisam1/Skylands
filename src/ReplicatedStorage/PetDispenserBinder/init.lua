local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local PetDispenser = require(script.PetDispenser)

local PetDispenserBinder = Binder.new(Enums.Tags.PetDispenser, PetDispenser)

PetDispenserBinder:Init()

return PetDispenserBinder
