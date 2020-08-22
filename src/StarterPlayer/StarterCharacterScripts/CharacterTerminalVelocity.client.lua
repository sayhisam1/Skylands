local RunService = game:GetService("RunService")

local MAX_VELOCITY = -1000
local player = game.Players.LocalPlayer

local char = player.Character

RunService.Heartbeat:Connect(
    function()
        local vel = char.PrimaryPart.Velocity
        char.PrimaryPart.Velocity = Vector3.new(vel.X, math.max(MAX_VELOCITY, vel.Y), vel.Z)
    end
)
