local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local Meteor = ASSETS:WaitForChild("Meteor")

local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local GetTaggedInstance = require(ReplicatedStorage.Objects.Promises.GetTaggedInstance)

local playerDebounce = {}
GetTaggedInstance("DAILY_CHEST"):andThen(function(chest)
    local TouchPart = chest:WaitForChild("TouchPart")
    TouchPart.Touched:Connect(function(p)
        local char = p.Parent
        if char:FindFirstChild("Humanoid") then
            local plr =
        end
        if not debounce and p:IsDescendantOf(game.Players.LocalPlayer.Character) then
        end
    end)
end)
