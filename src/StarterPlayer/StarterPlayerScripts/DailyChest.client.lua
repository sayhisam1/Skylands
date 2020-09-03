local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local Meteor = ASSETS:WaitForChild("Meteor")

local CameraShaker = require(ReplicatedStorage.Utils.CameraShaker)
local Numerical = require(ReplicatedStorage.Utils.Numerical)
local VectorUtil = require(ReplicatedStorage.Utils.VectorUtil)
local GetTaggedInstance = require(ReplicatedStorage.Objects.Promises.GetTaggedInstance)

local dirtPart = Instance.new("Part")
dirtPart.Anchored = false
dirtPart.CanCollide = false
dirtPart.Color = Color3.fromRGB(110, 59, 0)
dirtPart.Size = Vector3.new(2,2,2)
local debounce = false
GetTaggedInstance("DAILY_CHEST"):andThen(function(chest)
    local TouchPart = chest:WaitForChild("TouchPart")
    local AnimationController = chest:WaitForChild("AnimationController")
    local OpenAnimation = AnimationController:WaitForChild("Open")
    local OpenedAnimation = AnimationController:WaitForChild("Opened")
    local track = AnimationController:LoadAnimation(OpenAnimation)
    local track2 = AnimationController:LoadAnimation(OpenedAnimation)
    TouchPart.Touched:Connect(function(p)
        if not debounce and p:IsDescendantOf(game.Players.LocalPlayer.Character) then
            debounce = true
            local init = Vector3.new(-101.841, 50012.066, -127.879)
            local s = init + Vector3.new(1000, 1000, 1000)
            local e = init
            local g = Vector3.new(0, -9, 0)
            local m = Meteor:Clone()
            track:Play()
            wait(.2)
            track2:Play()
            wait(1)
            m.Parent = workspace
            local path = Numerical.BallisticMotion(s, e, g)
            for i=0,1,.01 do
                local n = path(i)
                m:SetPrimaryPartCFrame(CFrame.new(n))
                wait()
            end
            m:SetPrimaryPartCFrame(CFrame.new(e))
            m.Boom:Play()
            local cam = game.Workspace.Camera
            local function shakeCam(cf)
                cam.CFrame = cam.CFrame * cf
            end
            local camShake = CameraShaker.new(Enum.RenderPriority.Camera.Value + 1, shakeCam)
            camShake:Start()
            camShake:StartShake(30, 10)
            camShake:StopSustained(1)
            wait(1)
            camShake:Stop()
            debounce = false
        end
    end)
end)
