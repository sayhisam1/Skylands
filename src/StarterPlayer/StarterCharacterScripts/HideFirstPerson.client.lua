local RunService = game:GetService("RunService")
local player = game.Players.LocalPlayer
local character = player.Character

local isHidden = false
RunService.Heartbeat:Connect(
    function()
        local camdist = (game.Workspace.Camera.CFrame.Position - character.Head.Position).Magnitude
        if camdist < 3 and not isHidden then
            isHidden = true
            for _, v in pairs(character:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Enabled = false
                    v:Clear()
                elseif v:IsA("BillboardGui") then
                    v.Enabled = false
                end
            end
        elseif camdist >= 3 and isHidden then
            isHidden = false
            for _, v in pairs(character:GetDescendants()) do
                if (v:IsA("ParticleEmitter") and not v.Parent.Name:match("Portal")) or v:IsA("BillboardGui") then
                    v.Enabled = true
                end
            end
        end
    end
)
