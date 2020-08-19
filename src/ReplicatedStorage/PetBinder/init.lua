local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Pet = require(script.Pet)

local PetBinder = Binder.new(Enums.Tags.Pet, Pet)

PetBinder:Init()

return PetBinder
