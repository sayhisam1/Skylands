local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Spring = require(ReplicatedStorage.Objects.Shared.Spring)
local Welding = require(ReplicatedStorage.Utils.Welding)

local MULT = 1
return function(pet)
    local primaryPart = pet:GetInstance().PrimaryPart
    local player = pet:GetInstance().Parent
    local character = player.Character
    local charaPart = character.PrimaryPart
    primaryPart.Massless = true
    primaryPart.Anchored = true

    local springTarget = Vector3.new(math.random() * 6 - 3, math.random() * 2 + 1, math.random() * 6 - 3)
    pet:GetInstance():SetPrimaryPartCFrame(CFrame.new(springTarget + charaPart.Position))
    local spring = Spring.new(charaPart.CFrame:PointToWorldSpace(springTarget))
    pet._maid:GiveTask(RunService.Heartbeat:Connect(function(step)
        spring.Target = charaPart.CFrame:PointToWorldSpace(springTarget + Vector3.new(math.random() * 10 - 5, math.random() * 20 - 5, math.random() * 10 - 5))
        local diff = (spring.Target - spring.Position)
        local vel = diff * MULT * step
        spring:Impulse(vel)
        pet:GetInstance():SetPrimaryPartCFrame(((primaryPart.CFrame - primaryPart.CFrame.p) + spring.Position) * CFrame.Angles(0, math.random()*.01, 0))
    end))
end