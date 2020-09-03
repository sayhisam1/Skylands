local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Welding = require(ReplicatedStorage.Utils.Welding)

return function(backpack, character)
    local primaryPart = backpack:GetInstance().PrimaryPart
    local torso = character:WaitForChild("UpperTorso")
    local weld = Welding.weldTogether(torso, primaryPart, CFrame.new(0, 0, .5) * CFrame.Angles(0, math.pi, 0))
    if weld then
        backpack._maid:GiveTask(weld)
        backpack:GetInstance().Parent = character
    end
end
