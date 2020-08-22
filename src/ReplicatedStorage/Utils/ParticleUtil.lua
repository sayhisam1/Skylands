--Tool object is the main controller for tools
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Players = game:GetService("Players")

local ParticleEvent
if IsServer then
	ParticleEvent = Instance.new("RemoteEvent")
	ParticleEvent.Name = "PARTICLE"
	ParticleEvent.Parent = script
else
	ParticleEvent = script:WaitForChild("PARTICLE")
end

local channel = NetworkChannel.new("PARTICLE", ParticleEvent)

local ParticleUtil = {}

if IsClient then
	channel:Subscribe(
		"Emit",
		function(sound, options)
			ParticleUtil.PlaySound(sound, options)
		end
	)
end

local base_part = Instance.new("Part")
base_part.Anchored = true
base_part.CanCollide = false
base_part.Transparency = 1
local base_attach = Instance.new("Attachment")
base_attach.Parent = base_part
base_attach.Name = "PARTICLE_ATTACH"

function ParticleUtil.EmitParticleAtPosition(particle, position, options)
	options = options or {}
	assert(type(options) == "table", "Invalid options specified!")
	assert(type(position) == "userdata", "Invalid position!")
	assert(particle:IsA("ParticleEmitter"), "Tried to emit unknown particle " .. tostring(particle))

	local total_emit_time = options.TotalEmitTime
	options.TotalEmitTime = nil

	local particleClone = particle:Clone()
	game.Debris:AddItem(particleClone, particleClone.Lifetime.Max + 5)

	for option, value in pairs(options) do
		particleClone[option] = value
	end

	local lifespan = (total_emit_time or 0) + particleClone.Lifetime.Max + .5

	local particleMaid = Maid.new()
	particleMaid:GiveTask(particleClone)

	local new_part = base_part:Clone()
	new_part.Name = particleClone.Name
	game.Debris:AddItem(new_part, lifespan)
	new_part.CFrame = CFrame.new(position)
	particleClone.Parent = new_part
	new_part.Parent = game.Workspace
	local attach = new_part:FindFirstChild(base_attach.Name)
	particleClone.Parent = attach

	CollectionService:AddTag(new_part, "TEMPORARY")
	particleMaid:GiveTask(new_part)

	if total_emit_time then
		coroutine.wrap(
			function()
				wait(total_emit_time)
				particleClone.Enabled = false
				wait(particleClone.Lifetime.Max + 1)
				particleMaid:Destroy()
			end
		)()
		particleClone.Enabled = true
	end

	particleClone:Emit()
	return particleClone
end

if IsServer then
	function ParticleUtil.ReplicateParticleForPlayer(plr, sound, options)
		channel:PublishPlayer(plr, "Emit", sound, options)
	end
	function ParticleUtil.ReplicateParticleForPlayersExcept(ignored_plr, ...)
		for _, plr in pairs(Players:GetPlayers()) do
			if ignored_plr ~= plr then
				ParticleUtil.ReplicateParticleForPlayer(plr, ...)
			end
		end
	end
end

return ParticleUtil
