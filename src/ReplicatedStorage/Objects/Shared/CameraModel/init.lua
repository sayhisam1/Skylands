local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local CameraModel = setmetatable({}, BaseObject)

CameraModel.__index = CameraModel
CameraModel.ClassName = script.Name

function CameraModel.new(camera, instance)
    assert(camera:IsA("Camera"), "Invalid Camera!")
    assert(type(instance) == "userdata", "Invalid CameraModel!")
    assert(instance.PrimaryPart, "CameraModel has no Primary Part!")

    local self = setmetatable(BaseObject.new(instance.Name), CameraModel)

    self._instance = instance:Clone()
    self._camera = camera
    self._maid:GiveTask(self._instance)
    return self
end

function CameraModel:Render(offset)
    assert(typeof(offset) == "CFrame", "Invalid offset!")
    local inst = self._instance
    inst.Parent = self._camera
    self._maid["Heartbeat"] = RunService.Heartbeat:Connect(function()
        local cam_cf = self._camera.CFrame
        inst:SetPrimaryPartCFrame(cam_cf * offset)
    end)
end

return CameraModel