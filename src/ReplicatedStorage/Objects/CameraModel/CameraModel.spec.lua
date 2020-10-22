local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CameraModel = require(ReplicatedStorage.Objects.Shared.CameraModel)

return function()
    if RunService:IsClient() then
        describe(
            "Cam Model create",
            function()
                itSKIP(
                    "Should create cam model",
                    function()
                        local testPart = Instance.new("Part")
                        testPart.Anchored = true
                        testPart.CanCollide = false

                        local testModel = Instance.new("Model")
                        testPart.Parent = testModel
                        testModel.PrimaryPart = testPart
                        local camModel = CameraModel.new(Workspace.CurrentCamera, testModel)
                        camModel:Render(CFrame.new(0, 0, -5))
                        wait(10)
                        camModel:Destroy()
                        testModel:Destroy()
                    end
                )
            end
        )
    end
end
