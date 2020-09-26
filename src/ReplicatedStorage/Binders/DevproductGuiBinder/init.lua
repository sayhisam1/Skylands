local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local DevproductBuyGui = require(script.DevproductBuyGui)

local DevproductGuiBinder = Binder.new(Enums.Tags.DevproductBuyGui, DevproductBuyGui)

DevproductGuiBinder:Init()

return DevproductGuiBinder
