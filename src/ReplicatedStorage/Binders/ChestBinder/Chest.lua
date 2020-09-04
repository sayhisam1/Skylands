local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Chest = setmetatable({}, InstanceWrapper)

Chest.__index = Chest
Chest.ClassName = script.Name

function Chest.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Chest!")
    local self = setmetatable(InstanceWrapper.new(instance), Chest)
    self:Log(3, "Creating chest", instance:GetFullName())
    self:Setup()
    return self
end

function Chest:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Chest:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Chest:Setup()
    if self._isSetup then
        return
    end
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientChestSetup") or script.Parent.ClientChestSetup
    else
        setup = self:GetAttribute("ServerChestSetup") or script.Parent.ServerChestSetup
    end
    require(setup)(self)
end

return Chest
