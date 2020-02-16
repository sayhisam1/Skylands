local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Effect = require("Effect")
local Maid = require("Maid")
local AnchoredBlockModelMover = setmetatable({}, Effect)
AnchoredBlockModelMover.__index = AnchoredBlockModelMover
AnchoredBlockModelMover.Name = script.Name

local Debris = game:GetService("Debris")
function AnchoredBlockModelMover:New(owner, model, max_lifespan)
    self.__index = self
    local obj = setmetatable(Effect:New(), self)
    obj._model = model
    obj._maid = Maid.new()
    obj._maid:GiveTask(model)
    obj._maxLifespan = max_lifespan
    Debris:AddItem(model, max_lifespan)
    if IsServer and not owner.IsBot then
        _G.Services.EffectsService:HideModelForClient(owner, obj._model)
    end
    obj._owner = owner
    obj._started = false
    return obj
end

function AnchoredBlockModelMover:Start(cf)
    if self._model == nil or self._model.Parent == nil then
        return true -- return true to break projectile effect
    end
    -- -- Don't move the block if on server (should be handled locally by each player)
    -- if IsServer then
    --     return
    -- end
    self._model:SetPrimaryPartCFrame(cf)
end

function AnchoredBlockModelMover:Stop()
    self._maid:Destroy()
end
return AnchoredBlockModelMover
