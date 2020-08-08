local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Enums = require(ReplicatedStorage.Enums)

local Queue = require(ReplicatedStorage.Objects.Shared.Queue)
local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Backpack = require(script.Backpack)

local BackpackBinder = Binder.new(Enums.Tags.Backpack, Backpack)

BackpackBinder:Init()

return BackpackBinder
