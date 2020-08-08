local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)
local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)
local Pickaxe = setmetatable({}, InstanceWrapper)

Pickaxe.__index = Pickaxe
Pickaxe.ClassName = script.Name

function Pickaxe.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Tool"), "Invalid Pickaxe!")
    local self = setmetatable(InstanceWrapper.new(instance), Pickaxe)

    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPickaxeSetup") or script.Parent.ClientPickaxeSetup
    else
        setup = self:GetAttribute("ServerPickaxeSetup") or script.Parent.ServerPickaxeSetup
    end
    require(setup)(self)
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

return Pickaxe
