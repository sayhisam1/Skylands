local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Event = require(ReplicatedStorage.Objects.Shared.Event)
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

function Pet:GetAbilityButtonPressedSignal()
    assert(RunService:IsClient(), "Can only be called on client!")
    local Services = require(ReplicatedStorage.Services)
    local GuiController = Services.GuiController
    if not self._abilityButtonPressed then
        self._abilityButtonPressed = Event.new()
        self._maid["AbilityButtonPressed"] = self._abilityButtonPressed
        local destroy, transparency = GuiController:AddPetAbilityButton(self:GetInstance(), function(...)
            self._abilityButtonPressed:Fire(...)
        end)
        self._maid["AbilityButton"] = destroy
        self._updateTransparency = transparency
    end
    return self._abilityButtonPressed, self._updateTransparency
end

function Pet:SetupAbilities(player)
    local abilities
    if RunService:IsClient() and game.Players.LocalPlayer == player then
        abilities = self:WaitForChildPromise("Abilities"):expect()
    else
        abilities = self:FindFirstChild("Abilities")
    end
    self:Log(3, "Setup abilities", abilities:GetChildren())
    for _, v in pairs(abilities:GetChildren()) do
        if RunService:IsClient() then
            self._maid[v.Name] = require(v).LoadClient(self, player)
        else
            self._maid[v.Name] = require(v).LoadServer(self, player)
        end
    end
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
