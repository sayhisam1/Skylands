local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Effect = require("Effect")
local Maid = require("Maid")
local UnanchoredBlockModelMover = setmetatable({}, Effect)
UnanchoredBlockModelMover.__index = UnanchoredBlockModelMover

local Debris = game:GetService("Debris")
function UnanchoredBlockModelMover:New(owner, model, max_lifespan)
    self.__index = self
    local obj = setmetatable(Effect:New(), self)
    obj._maid = Maid.new()
    obj._model = model
    obj._maid:GiveTask(model)
    Debris:AddItem(model, max_lifespan)
    local bodyp = Instance.new("BodyPosition")
    local bodyg = Instance.new("BodyGyro")
    bodyg.Parent = model.PrimaryPart
    bodyp.Parent = model.PrimaryPart

    local MaxForce = Vector3.new(100, 100, 100)
    bodyg.MaxTorque = MaxForce
    bodyp.MaxForce = MaxForce

    local D = 1
    bodyg.D = D
    bodyp.D = D

    local P = 1
    bodyg.P = P
    bodyp.P = P

    local init_cf = model.PrimaryPart.CFrame

    bodyg.CFrame = init_cf
    bodyp.Position = init_cf.Position

    for _, descendant in pairs(model:GetDescendants()) do
        if descendant:IsA("BasePart") then
            descendant.Massless = true
            descendant.CanCollide = false
            descendant.Anchored = false
        end
    end

    obj._bodyp = bodyp
    obj._bodyg = bodyg
    obj._owner = owner
    return obj
end

function UnanchoredBlockModelMover:Start(cf)
    self._bodyg.CFrame = cf
    self._bodyp.Position = cf.Position
    if (self._model.PrimaryPart.CFrame.Position - cf.Position).Magnitude > 10 then
        self._model:SetPrimaryPartCFrame(cf)
    end
end

function UnanchoredBlockModelMover:Stop()
    self._maid:Destroy()
end

return UnanchoredBlockModelMover
