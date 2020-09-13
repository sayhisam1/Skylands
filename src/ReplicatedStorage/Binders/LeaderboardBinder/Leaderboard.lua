local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Leaderboard = setmetatable({}, InstanceWrapper)

Leaderboard.__index = Leaderboard
Leaderboard.ClassName = script.Name

function Leaderboard.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Leaderboard!")
    local self = setmetatable(InstanceWrapper.new(instance), Leaderboard)

    self:Setup()

    return self
end

function Leaderboard:SetCFrame(cframe)
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Leaderboard:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Leaderboard:GetCharacter()
    return self:GetInstance().Parent
end

function Leaderboard:Setup()
    if self._isSetup or self._destroyed then
        return
    end
    self._maid["SetupHook"] = nil
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientLeaderboardSetup") or script.Parent.ClientLeaderboardSetup
    else
        setup = self:GetAttribute("ServerLeaderboardSetup") or script.Parent.ServerLeaderboardSetup
    end
    require(setup)(self)
end

return Leaderboard
