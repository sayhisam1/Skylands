local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Services = require(ReplicatedStorage.Services)

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)
local Pet = setmetatable({}, InstanceWrapper)

Pet.__index = Pet
Pet.ClassName = script.Name

function Pet.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Pet!")
    local self = setmetatable(InstanceWrapper.new(instance), Pet)

    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPetSetup") or script.Parent.ClientPetSetup
    else
        setup = self:GetAttribute("ServerPetSetup") or script.Parent.ServerPetSetup
    end
    require(setup)(self)
    return self
end

function Pet:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Pet:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Pet:GetCharacter()
    return self:GetInstance().Parent
end

return Pet
