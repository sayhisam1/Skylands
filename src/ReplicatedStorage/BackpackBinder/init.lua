local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Backpack = require(script.Backpack)

local BackpackBinder = Binder.new(Enums.Tags.Backpack, Backpack)

BackpackBinder:Init()

return BackpackBinder
