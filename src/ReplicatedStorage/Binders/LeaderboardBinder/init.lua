local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Enums = require(ReplicatedStorage.Enums)

local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Leaderboard = require(script.Leaderboard)

local LeaderboardBinder = Binder.new(Enums.Tags.Leaderboard, Leaderboard)

LeaderboardBinder:Init()

return LeaderboardBinder
