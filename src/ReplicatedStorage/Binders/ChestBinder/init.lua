local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Chest = require(script.Chest)

local ChestBinder = Binder.new(Enums.Tags.Chest, Chest)

ChestBinder:Init()

return ChestBinder
