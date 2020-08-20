local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Welding = require(ReplicatedStorage.Utils.Welding)

return function(backpack)
    local primaryPart = backpack:GetInstance().PrimaryPart
    local player = backpack:GetInstance().Parent
    pcall(
        function()
            local character = player.Character
            local torso = character:FindFirstChild("UpperTorso")
            backpack._maid:GiveTask(Welding.weldTogether(torso, primaryPart, CFrame.new(0, 0, .5) * CFrame.Angles(0, math.pi, 0)))
        end
    )
end
