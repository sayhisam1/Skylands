local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Teleporter = require(script.Teleporter)

local TeleporterBinder = Binder.new(Enums.Tags.Teleporter, Teleporter)

TeleporterBinder:Init()

return TeleporterBinder
