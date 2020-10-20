local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Pickaxe = require(script.Pickaxe)

local PickaxeBinder = Binder.new(Enums.Tags.Pickaxe, Pickaxe)

PickaxeBinder:Init()

return PickaxeBinder
