local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Enums = require(ReplicatedStorage.Enums)

local Queue = require(ReplicatedStorage.Objects.Shared.Queue)
local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Pet = require(script.Pet)

local PetBinder = Binder.new(Enums.Tags.Pet, Pet)

PetBinder:Init()

return PetBinder
