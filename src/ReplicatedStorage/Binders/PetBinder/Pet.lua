local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local AttackContext = require(ReplicatedStorage.Objects.Abstract.AttackContext)
local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Pet = setmetatable({}, InstanceWrapper)

Pet.__index = Pet
Pet.ClassName = script.Name

function Pet.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Pet!")
    local self = setmetatable(InstanceWrapper.new(instance), Pet)

    self._maid["SetupHook"] = instance.AncestryChanged:Connect(function()
        self:Setup()
    end)

    self:Setup()

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

function Pet:GetAbilityContext()
    if not self._abilityContext then
        self._abilityContext = AttackContext.new()
        self._maid["AbilityContext"] = self._abilityContext
    end
    return self._abilityContext
end

function Pet:Setup()
    if self._isSetup or self._destroyed then
        return
    end
    if not self._instance:IsDescendantOf(Players) then
        return
    end
    if RunService:IsClient() then
        local PlayerGui = game.Players.LocalPlayer.PlayerGui
        if self._instance:IsDescendantOf(PlayerGui) then
            return
        end
    end
    self._maid["SetupHook"] = nil
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPetSetup") or script.Parent.ClientPetSetup
    else
        setup = self:GetAttribute("ServerPetSetup") or script.Parent.ServerPetSetup
    end
    require(setup)(self)
end

return Pet
