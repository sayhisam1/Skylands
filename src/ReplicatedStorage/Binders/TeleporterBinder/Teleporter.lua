local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Teleporter = setmetatable({}, InstanceWrapper)

Teleporter.__index = Teleporter
Teleporter.ClassName = script.Name

function Teleporter.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Teleporter!")
    local self = setmetatable(InstanceWrapper.new(instance), Teleporter)
    self:Log(3, "Creating teleporter", instance:GetFullName())
    self:Setup()
    return self
end

function Teleporter:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Teleporter:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Teleporter:Setup()
    if self._isSetup then
        return
    end
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientTeleporterSetup") or script.Parent.ClientTeleporterSetup
    else
        setup = self:GetAttribute("ServerTeleporterSetup") or script.Parent.ServerTeleporterSetup
    end
    require(setup)(self)
end

return Teleporter
