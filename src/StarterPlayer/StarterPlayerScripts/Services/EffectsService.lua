--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"SoundService"}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------
local Ragdoll = require("RagdollClient")
local Debris = game:GetService("Debris")
local Maid = require("Maid").new()
local ConnectedEvents = {}
local EffectsDir = nil
local ServerEffectsDir = nil
local LocalEffectsDir = nil

local EffectsNetworkChannel

function Service:Load()
    EffectsDir = game.Workspace:WaitForChild("Effects")
    ServerEffectsDir = EffectsDir:WaitForChild("ServerEffects")
    LocalEffectsDir = Instance.new("Folder")
    LocalEffectsDir.Parent = EffectsDir
    LocalEffectsDir.Name = "LocalEffects"
    EffectsNetworkChannel = self:GetNetworkChannel()

    -- setup subscriptions

    EffectsNetworkChannel:Subscribe(
        "ReplicateProjectile",
        function(packaged, ...)
            local ProjectileEffect = require("ProjectileEffect")
            local effect = ProjectileEffect:Unpackage(packaged)
            effect:Start(...)
        end
    )

    EffectsNetworkChannel:Subscribe(
        "HideModel",
        function(...)
            local models = {...}
            for _, model in pairs(models) do
                model:Destroy()
            end
        end
    )
    EffectsNetworkChannel:Subscribe(
        "Ragdoll",
        function(char)
            local hum = char:FindFirstChildOfClass("Humanoid")

            local d = char:GetDescendants()
            for i = 1, #d do
                local desc = d[i]
                if desc:IsA("Motor6D") then
                    local socket = Instance.new("BallSocketConstraint")
                    local part0 = desc.Part0
                    local joint_name = desc.Name
                    local attachment0 =
                        desc.Parent:FindFirstChild(joint_name .. "Attachment") or
                        desc.Parent:FindFirstChild(joint_name .. "RigAttachment")
                    local attachment1 =
                        part0:FindFirstChild(joint_name .. "Attachment") or
                        part0:FindFirstChild(joint_name .. "RigAttachment")
                    if attachment0 and attachment1 then
                        socket.Attachment0, socket.Attachment1 = attachment0, attachment1
                        socket.Parent = desc.Parent
                        desc:Destroy()
                    end
                end
            end
            char.Parent = LocalEffectsDir
            Debris:AddItem(char, 10)
        end
    )
    EffectsNetworkChannel:Subscribe(
        "SoundEffect",
        function(...)
            _G.Services.SoundService:PlaySound(...)
        end
    )

    EffectsNetworkChannel:Subscribe(
        "EmitParticleAtPosition",
        function(particle_name, position)
            self:EmitParticleAtPosition(particle_name, position)
        end
    )
end

function Service:GetEffectsDir()
    return LocalEffectsDir
end

function Service:GetLocalEffectsDir()
    return LocalEffectsDir
end

function Service:GetServerEffectsDir()
    return ServerEffectsDir
end

function Service:GetRootEffectsFolder()
    return EffectsDir
end

function Service:Unload()
    local effects = game.Workspace:WaitForChild("Effects")
    while (effects:FindFirstChild("LocalEffects")) do
        effects:FindFirstChild("LocalEffects"):Destroy()
    end
    EffectsDir = nil
end

local DEFAULT_PART_BLOCK = Instance.new("Part")
DEFAULT_PART_BLOCK.Anchored = true
DEFAULT_PART_BLOCK.CanCollide = false
DEFAULT_PART_BLOCK.Position = Vector3.new(0,-10,0)
DEFAULT_PART_BLOCK.Size = Vector3.new(1,1,1)
DEFAULT_PART_BLOCK.Transparency = 1
function Service:EmitParticleAtPosition(particle_name, position)
    local p = DEFAULT_PART_BLOCK:Clone()
    Debris:AddItem(p, 1)
    p.Position = position
    p.Parent = LocalEffectsDir
    local Att = Instance.new("Attachment")
    Att.Parent = p
    local particle = ReplicatedStorage.Assets.Particles:FindFirstChild(particle_name):Clone()
    particle.Enabled = false
    particle.Parent = Att
    p.Parent = LocalEffectsDir
    particle:Emit()
end

return Service
