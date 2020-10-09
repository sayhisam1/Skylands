local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local ORES = ReplicatedStorage:WaitForChild("Ores")
    local MockPlayer = require(ReplicatedStorage.Objects.Shared.MockPlayer)
    local OreBinder = require(ReplicatedStorage.Binders.OreBinder)
    -- monkeypatch IsPlayer --
    -- local ds2 = ReplicatedStorage.Lib.DataStore2
    -- local isplayer = ds2.IsPlayer
    -- require(isplayer).Check = function(object)
    --     return (typeof(object) == "Instance" and object.ClassName == "Player") or object.ClassName == "Player"
    -- end
    if RunService:IsClient() then
        return
    end
    describe(
        "ore mine test",
        function()
            for i, v in ipairs(ORES:GetChildren()) do
                it(
                    "should mine " .. v.Name,
                    function()
                        local plr = MockPlayer()
                        local clone = v:Clone()
                        clone:SetPrimaryPartCFrame(CFrame.new(10 * i, 1E5, 10 * i))
                        clone.Parent = Workspace
                        local ore = OreBinder:Bind(clone)
                        ore:Mine(plr, 1)
                        ore:Mine(plr, math.huge)
                        ore:Destroy()
                        plr:Destroy()
                    end
                )
            end
        end
    )
end
