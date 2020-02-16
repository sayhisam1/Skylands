local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Effect = require("Effect")
local Maid = require("Maid")
local CreateCFrameArrowEffect = setmetatable({}, Effect)
CreateCFrameArrowEffect.__index = CreateCFrameArrowEffect

local ARROW_COLOR = (IsServer and Color3.fromRGB(255, 0, 0)) or Color3.fromRGB(0, 0, 255)
function CreateCFrameArrowEffect:New(owner, properties)
    self.__index = self
    local obj = setmetatable(Effect:New(), self)
    obj._maid = Maid.new()
    obj._properties = properties or {}
    obj._owner = owner
    return obj
end

function CreateCFrameArrowEffect:Start(cf)
    if IsServer then
        local p = Instance.new("Part")
        p.Anchored = true
        p.CanCollide = false
        p.Size = Vector3.new(.05, .05, .25)
        p.CFrame = cf
        p.Transparency = .7
        p.Color = ARROW_COLOR
        p.Parent = _G.Services.EffectsService:GetServerEffectsDir()
        game.Debris:AddItem(p, 10)
        if self._owner and not self._owner.IsBot and not p.Anchored then
            p:SetNetworkOwner(self._owner:GetReference())
        end
    end
end

function CreateCFrameArrowEffect:Stop()
end

return CreateCFrameArrowEffect
