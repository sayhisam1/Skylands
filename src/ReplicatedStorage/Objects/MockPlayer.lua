local Players = game:GetService("Players")
return function()
    local obj = newproxy(true)
    local MockPlayer = getmetatable(obj)
    MockPlayer.__index = MockPlayer
    MockPlayer.ClassName = "Player"
    MockPlayer.UserId = -1337
    MockPlayer.Character = nil
    MockPlayer.Parent = Players
    MockPlayer.AncestryChanged = {
        Connect = function()
        end
    }
    function MockPlayer:IsA(a)
        if a == "Player" or a == "Instance" or a == "MockPlayer" then
            return true
        end
    end
    function MockPlayer:Destroy()
        MockPlayer.Character:Destroy()
    end
    return obj
end
