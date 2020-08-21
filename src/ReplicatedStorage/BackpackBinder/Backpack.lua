local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Backpack = setmetatable({}, InstanceWrapper)

Backpack.__index = Backpack
Backpack.ClassName = script.Name

function Backpack.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Backpack!")
    local self = setmetatable(InstanceWrapper.new(instance), Backpack)

    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientBackpackSetup") or script.Parent.ClientBackpackSetup
    else
        setup = self:GetAttribute("ServerBackpackSetup") or script.Parent.ServerBackpackSetup
    end
    require(setup)(self)
    return self
end

function Backpack:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Backpack:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Backpack:GetCharacter()
    return self:GetInstance().Parent
end

return Backpack
