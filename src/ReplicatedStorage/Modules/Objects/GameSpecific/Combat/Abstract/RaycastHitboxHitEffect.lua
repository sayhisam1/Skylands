local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local DEBUGMODE = false

local Maid = require("Maid")

local Effect = require("HitDetectingEffect")
local RaycastHitboxHitEffect = setmetatable({}, Effect)
RaycastHitboxHitEffect.__index = RaycastHitboxHitEffect
RaycastHitboxHitEffect.Name = script.Name

function RaycastHitboxHitEffect:New(owner, rootpart, frame_skip)
    self.__index = self
    assert(type(rootpart) == 'userdata', "Invalid root part!")
    local obj = setmetatable(Effect:New(owner), self)
    obj._rootPart = rootpart
    obj._frameSkip = frame_skip or 2
    return obj
end

function RaycastHitboxHitEffect:Destroy()
    self:Stop()
end

local function drawRay(ray)
    coroutine.wrap(
        function()
            local newp = Instance.new("Part")
            newp.Anchored = true
            newp.Transparency = .8
            newp.Color = (RunService:IsServer() and Color3.new(1, 0, 0)) or Color3.new(0, 1, 0)
            newp.Size = Vector3.new(.05, .05, ray.Direction.Magnitude)
            newp.CFrame = CFrame.new(ray.Origin, ray.Origin + ray.Direction) * CFrame.new(0, 0, newp.Size.Z * -.5)
            newp.CanCollide = false
            newp.Parent = game.Workspace.Effects
            local ori = Instance.new("Part")
            ori.Anchored = true
            ori.CanCollide = false
            ori.Color = Color3.new(0, 0, 1)
            ori.Size = Vector3.new(.1, .1, .1)
            ori.CFrame = CFrame.new(ray.Origin)
            ori.Parent = game.Workspace.Effects
            local Debris = game.Debris
            Debris:AddItem(newp, 5)
            Debris:AddItem(ori, 5)
            return newp
        end
    )()
end
function RaycastHitboxHitEffect:Start()
    local descendants = self._rootPart:GetDescendants()
    local hitboxAttachments = {}
    for _,v in pairs(descendants) do
        if v:IsA("Attachment") and v.Name == "HitboxRay" then
            hitboxAttachments[#hitboxAttachments+1] = v
        end
    end
    local oldAttachmentPositions = {}
    local function _updateAttachmentPositions(attachments)
        oldAttachmentPositions = {}
        for _,attachment in pairs(attachments) do
            oldAttachmentPositions[attachment] = attachment.WorldPosition
        end
    end
    _updateAttachmentPositions(hitboxAttachments)
    local skip = self._frameSkip
    local counter = 1
    local predictionScale = 1.2
    local ignore = {self:GetOwner():GetCharacter(),_G.Services.EffectsService:GetRootEffectsFolder()}
    local conn = RunService.Heartbeat:Connect(function(step)
        if counter % skip == 0 then
            counter = 1
            for _,attachment in pairs(hitboxAttachments) do
                local oldPos = oldAttachmentPositions[attachment]
                local newPos = attachment.WorldPosition
                local hitcastRay = Ray.new(oldPos, (newPos - oldPos)*predictionScale)
                local partHit, pos, normal = workspace:FindPartOnRayWithIgnoreList(hitcastRay, ignore)
                if partHit then
                    self:HandleHit(partHit, pos, normal)
                end
                if DEBUGMODE then
                    drawRay(hitcastRay)
                end
            end
            _updateAttachmentPositions(hitboxAttachments)
        else
            counter = counter+1
        end
    end)

    self._maid:GiveTask(conn)
end

function RaycastHitboxHitEffect:Stop()
    self._maid:Destroy()
end
return RaycastHitboxHitEffect
