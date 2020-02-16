--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

--MATH LIBRARY IMPORTS--
local Sin = math.sin
local Cos = math.cos
local aSin = math.asin
local Max = math.max
local Min = math.min
local Clamp = math.clamp
local Abs = math.abs
local newCF = CFrame.new
local newV3 = Vector3.new
local newRay = Ray.new
local CFAngles = CFrame.Angles
local PI = 3.14

local RS = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")
local UIS = game:GetService("UserInputService")

local SENSITIVITY_X = 2
local SENSITIVITY_Y = 2
local START_X = 0
local START_Y = 0
local START_Z = 8
local RADIUS = 15
local START_FRAME = newCF(newV3(0, 0, 0))
local CAMERA_IGNORE = {}

local angleY = 0
local angleX = 0
local cameraOffset = newV3(0, 2, 1)
local isFrozen = false

local _CameraTarget = nil
local _CameraPlayerGyro = nil
local binds = {}

local _CharacterWaist = nil

local tweening = false

function Service:Load()
    --	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
    --	workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
    --	self:StartTracking()
end
function Service:Unload()
    --	for i,v in pairs(binds) do
    --		v:Disconnect()
    --	end
    --	CAS:UnbindAction("Camera Move")
    --	CAS:UnbindAction("Camera Resize")
    --	binds = {}
    --	Service:SetCameraTarget(nil)
end

local camera_update_count = 1
local current_popper_update_limit = 4
local previous_radius = RADIUS
function UpdateTick()
    if (not _CameraTarget) then
        return
    end

    local from_point =
        newV3(RADIUS * Sin(angleX) * Sin(angleY), RADIUS * Cos(angleY), RADIUS * Cos(angleX) * Sin(angleY)) +
        _CameraTarget.CFrame:pointToWorldSpace(cameraOffset)
    local target_point = _CameraTarget.CFrame:pointToWorldSpace(cameraOffset)

    local in_the_way, position =
        game.Workspace:FindPartOnRayWithWhitelist(newRay(target_point, from_point - target_point), CAMERA_IGNORE)
    if (in_the_way) then
        --print("Part in the way! "..in_the_way:GetFullName())
        local tmp_radius = ((position - target_point).Magnitude + previous_radius) / 2
        previous_radius = tmp_radius
        from_point =
            newV3(
            tmp_radius * Sin(angleX) * Sin(angleY),
            tmp_radius * Cos(angleY),
            tmp_radius * Cos(angleX) * Sin(angleY)
        ) + _CameraTarget.CFrame:pointToWorldSpace(cameraOffset)
    end

    local new_frame = newCF(from_point, target_point)

    workspace.CurrentCamera.CFrame = new_frame
end

function UpdateAngles(_, state, input)
    local delta = input.Delta
    local viewX = input.Position.X
    local viewY = input.Position.Y

    local dX = delta.X * (PI / (-2 * viewY)) * SENSITIVITY_X
    local dY = delta.Y * (PI / (-2 * viewY)) * SENSITIVITY_Y

    angleY = Min(3, Max(.2, angleY + dY))
    angleX = angleX + dX

    return Enum.ContextActionResult.Pass
end

function UpdateRadius(_, state, input)
    local delta = input.Position.Z * -3
    RADIUS = math.clamp(RADIUS + delta, 1, 50)

    return Enum.ContextActionResult.Pass
end

function Service:SetCameraTarget(obj)
    game.Workspace.CurrentCamera.CameraSubject = obj
    _CameraTarget = obj
end

function Service:GetCFrame()
    return game.Workspace.Camera.CFrame
end

function Service:StartTracking()
    cameraOffset = newV3(0, 2, 1)
    angleY = 0
    angleX = 0

    binds[#binds + 1] = RS.RenderStepped:Connect(UpdateTick)
    CAS:BindActionAtPriority("Camera Move", UpdateAngles, false, 3000, Enum.UserInputType.MouseMovement)

    CAS:BindActionAtPriority("Camera Resize", UpdateRadius, false, 3000, Enum.UserInputType.MouseWheel)
end
return Service
