local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Maid = require("Maid")

local Effect = require("HitDetectingEffect")
local OnTouchedHitEffect = setmetatable({}, Effect)
OnTouchedHitEffect.__index = OnTouchedHitEffect
OnTouchedHitEffect.Name = script.Name

function OnTouchedHitEffect:New(owner, rootpart)
    self.__index = self
    assert(type(rootpart) == 'userdata', "Invalid root part!")
    local obj = setmetatable(Effect:New(owner), self)
    obj._rootPart = rootpart
    return obj
end


function OnTouchedHitEffect:Destroy()
    self:Stop()
end

function OnTouchedHitEffect:Start()
    local conn = self._rootPart.Touched:Connect(function(part)
        self:HandleHit(part)
    end)
    self._maid:GiveTask(conn)
end

function OnTouchedHitEffect:Stop()
    self._maid:Destroy()
end
return OnTouchedHitEffect
