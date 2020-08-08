local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Enums = require(ReplicatedStorage.Enums)

local Queue = require(ReplicatedStorage.Objects.Shared.Queue)
local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Pickaxe = require(script.Pickaxe)

local PickaxeBinder = Binder.new(Enums.Tags.Pickaxe, Pickaxe)

PickaxeBinder:Init()

return PickaxeBinder
