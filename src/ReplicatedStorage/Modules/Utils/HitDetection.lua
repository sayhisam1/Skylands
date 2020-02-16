local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local DEBUGMODE = false

local PI = math.pi
local Sin = math.sin
local Cos = math.cos
local aSin = math.asin
local Max = math.max
local Min = math.min
local Abs = math.abs
local newCF = CFrame.new
local newCFAngles = CFrame.Angles
local newV3 = Vector3.new
local newRay = Ray.new
local newInstance = Instance.new
local newColor = Color3.new

local module = {}
local FindPartOnRayWithIgnoreList = game.Workspace.FindPartOnRayWithIgnoreList
local FindPartOnRayWithWhitelist = game.Workspace.FindPartOnRayWithWhitelist

local RunService = game:GetService("RunService")

local function rotate_vector(vector, theta)
    local x = vector.X
    local y = vector.Y
    local z = vector.Z
    local newVector = newV3(Cos(theta) * x - Sin(theta) * z, y, x * Sin(theta) + Cos(theta) * z)
    return newVector
end
local function drawRay(ray)
    spawn(
        function()
            local newp = Instance.new("Part")
            newp.Anchored = true
            newp.Transparency = .8
            newp.Color = (RunService:IsServer() and newColor(1, 0, 0)) or newColor(0, 1, 0)
            newp.Size = newV3(.05, .05, ray.Direction.Magnitude)
            newp.CFrame = newCF(ray.Origin, ray.Origin + ray.Direction) * newCF(0, 0, newp.Size.Z * -.5)
            newp.CanCollide = false
            newp.Parent = game.Workspace.Effects
            local ori = Instance.new("Part")
            ori.Anchored = true
            ori.CanCollide = false
            ori.Color = newColor(0, 0, 1)
            ori.Size = newV3(.1, .1, .1)
            ori.CFrame = newCF(ray.Origin)
            ori.Parent = game.Workspace.Effects
            local Debris = game.Debris
            Debris:AddItem(newp, 5)
            Debris:AddItem(ori, 5)
            return newp
        end
    )
end
function module:FindPartsInArc(
    position,
    direction,
    theta_min,
    theta_max,
    delta_theta,
    height_min,
    height_max,
    delta_height,
    distance,
    ignore)
    theta_min = theta_min or PI / 2
    theta_max = theta_max or PI / 2
    delta_theta = delta_theta or PI / 2

    height_min = height_min or .5
    height_max = height_max or .5
    delta_height = delta_height or 1

    distance = distance or 1

    ignore = ignore or {workspace.Effects}
    local parts_hit = {}
    for theta = -1 * theta_min, theta_max, delta_theta do
        for dY = -1 * height_min, height_max, delta_height do
            local new_direction = rotate_vector(direction, theta) + newV3(0, dY, 0)
            local new_ray = newRay(position, new_direction * distance / new_direction.Magnitude)
            local part, pos, norm = FindPartOnRayWithIgnoreList(workspace, new_ray, ignore, false, false)
            if DEBUGMODE then
                drawRay(new_ray)
            end
            if (part ~= nil and part:IsA("BasePart")) then
                parts_hit[#parts_hit + 1] = {
                    Part = part,
                    Position = pos,
                    SurfaceNorm = norm
                }
            end
        end
    end
    return parts_hit
end

return module
