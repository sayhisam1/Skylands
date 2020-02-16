--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------
local NetworkChannel = require("NetworkChannel")
local Debris = game:GetService("Debris")
local EffectsDir
local ServerEffectsDir
local EffectsNetworkChannel
local ReplicatedEffectsDir
function Service:Load()
    EffectsDir = workspace:FindFirstChild("Effects")
    if not EffectsDir then
        EffectsDir = Instance.new("Folder")
        EffectsDir.Name = "Effects"
        EffectsDir.Parent = workspace
    end
    ServerEffectsDir = EffectsDir:FindFirstChild("ServerEffects")
    if not ServerEffectsDir then
        ServerEffectsDir = Instance.new("Folder")
        ServerEffectsDir.Name = "ServerEffects"
        ServerEffectsDir.Parent = EffectsDir
    end
    ReplicatedEffectsDir = ReplicatedStorage:FindFirstChild("ReplicatedEffects")
    if not ReplicatedEffectsDir then
        ReplicatedEffectsDir = Instance.new("Folder")
        ReplicatedEffectsDir.Name = "ReplicatedEffects"
        ReplicatedEffectsDir.Parent = ReplicatedStorage
    end
    EffectsNetworkChannel = self:GetNetworkChannel()
end

function Service:GetEffectsDir()
    return ServerEffectsDir
end

function Service:GetServerEffectsDir()
    return ServerEffectsDir
end

function Service:GetRootEffectsFolder()
    return EffectsDir
end

function Service:HideModelForClient(client, ...)
    if not client.IsBot then
        EffectsNetworkChannel:PublishPlayer(client, "HideModel", ...)
    end
end

function Service:CreateReplicatedRagdoll(char, owner)
    char.Archivable = true
    char.Parent = ServerEffectsDir
    Debris:AddItem(char, 60)
    local hum = char:FindFirstChildOfClass("Humanoid")
    hum:SetStateEnabled(Enum.HumanoidStateType.Physics, true)
    hum:ChangeState(Enum.HumanoidStateType.Physics)
    hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    local animate_script = char:FindFirstChild("Animate")
    if animate_script and animate_script:IsA("Script") then
        animate_script:Destroy()
    end
    local tracks = hum:GetPlayingAnimationTracks()
    for _, track in pairs(tracks) do
        track:Stop()
    end
    EffectsNetworkChannel:Publish("Ragdoll", char)
end

function Service:ReplicateProjectile(projectile_effect, ...)
    local owner = projectile_effect._owner
    local packaged = projectile_effect:Package()
    local players = _G.Services.PlayerManager:GetNonBotPlayers()

    for _, player in pairs(players) do
        if not player.IsBot and player ~= owner then
            EffectsNetworkChannel:PublishPlayer(player, "ReplicateProjectile", packaged, ...)
        end
    end
end

function Service:ReplicateSound(plr, ...)
    EffectsNetworkChannel:PublishPlayer(plr, "SoundEffect", ...)
end

function Service:ReplicateEmitParticleAtPosition(player, particle_name, position)
    EffectsNetworkChannel:PublishPlayer(player, "EmitParticleAtPosition", particle_name, position)
end

function Service:Unload()
    ServerEffectsDir:Destroy()
    ServerEffectsDir = nil
    ReplicatedEffectsDir:Destroy()
    ReplicatedEffectsDir = nil
end
return Service
