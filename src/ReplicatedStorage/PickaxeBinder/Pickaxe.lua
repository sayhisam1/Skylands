local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Pickaxe = setmetatable({}, InstanceWrapper)

Pickaxe.__index = Pickaxe
Pickaxe.ClassName = script.Name

function Pickaxe.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Tool"), "Invalid Pickaxe!")
    local self = setmetatable(InstanceWrapper.new(instance), Pickaxe)

    self:Setup()
    return self
end

function Pickaxe:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Pickaxe:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Pickaxe:GetCharacter()
    return self:GetInstance().Parent
end

function Pickaxe:Setup()
    if self._isSetup then
        return
    end
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPickaxeSetup") or script.Parent.ClientPickaxeSetup
    else
        setup = self:GetAttribute("ServerPickaxeSetup") or script.Parent.ServerPickaxeSetup
    end
    require(setup)(self)
end

return Pickaxe
