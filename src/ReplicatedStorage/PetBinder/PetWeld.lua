local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Numerical = require(ReplicatedStorage.Utils.Numerical)
local Spring = require(ReplicatedStorage.Objects.Shared.Spring)

local MULT = 1
local PET_COUNTER = 0
return function(pet, character)
    local primaryPart = pet:GetInstance().PrimaryPart
    local charaPart = character:WaitForChild("HumanoidRootPart")
    primaryPart.Massless = true
    primaryPart.Anchored = true
    PET_COUNTER = (PET_COUNTER + 1) % 100 + 1
    local theta = Numerical.fibonacciSpiral(PET_COUNTER, 1)
    local rand = Random.new()
    local springTarget = Vector3.new(math.sin(theta) * rand:NextNumber(4, 6), rand:NextNumber(2, 3), math.cos(theta) * rand:NextNumber(4, 6))
    pet:GetInstance():SetPrimaryPartCFrame(CFrame.new(springTarget + charaPart.Position))
    local spring = Spring.new(charaPart.CFrame:PointToWorldSpace(springTarget))
    pet._maid:GiveTask(
        RunService.Heartbeat:Connect(
            function(step)
                spring.Target =
                    charaPart.CFrame:PointToWorldSpace(
                    springTarget + Vector3.new(rand:NextNumber(-5, 5), rand:NextNumber(-10, 10), rand:NextNumber(-5, 5))
                )
                local diff = (spring.Target - spring.Position)
                local vel = diff * MULT * step
                spring:Impulse(vel)
                pet:GetInstance():SetPrimaryPartCFrame(
                    ((primaryPart.CFrame - primaryPart.CFrame.p) + spring.Position) * CFrame.Angles(0, math.random() * .01, 0)
                )
            end
        )
    )
    pet:GetInstance().Parent = character
end
