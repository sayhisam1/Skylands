local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ropost = require(ReplicatedStorage.Lib.Ropost)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Players = game:GetService("Players")
local SoundUtil = {}

if IsClient then
	Ropost.subscribe(
		{
			channel = "SoundUtil",
			topic = "PlaySound",
			callback = function(data)
				SoundUtil.PlaySound(data.sound, data.options)
			end
		}
	)
end

function SoundUtil.PlaySound(sound, options)
	options = options or {}
	assert(type(options) == "table", "Invalid options specified!")
	assert(sound:IsA("Sound"), "Tried to play unkown sound " .. tostring(sound))

	if IsServer then
		local ignored_players = options.IgnoredPlayers
		options.IgnoredPlayers = nil
		if ignored_players then
			SoundUtil.ReplicateSoundForPlayersExcept(ignored_players, sound, options)
			return
		end

		local only_players = options.OnlyPlayers
		options.OnlyPlayers = nil
		if only_players then
			SoundUtil.ReplicateSoundForPlayersOnly(only_players, sound, options)
			return
		end

		SoundUtil.ReplicateSoundForPlayers(sound, options)
		return
	end

	local soundClone = sound:Clone()
	Debris:AddItem(soundClone, sound.TimeLength + 10)
	-- sound.SoundObj.Volume = sound.InitialVolume * (SoundSettings[sound.Group] or 1) * SoundSettings["Master"]
	-- Mask out extra options

	local position = options.Position
	options.Position = nil

	local pitchshift = options.PitchShift
	options.PitchShift = nil

	for option, value in pairs(options) do
		soundClone[option] = value
	end
	soundClone.Parent = game.SoundService

	local soundMaid = Maid.new()
	soundMaid:GiveTask(soundClone)

	if pitchshift then
		local ps = Instance.new("PitchShiftSoundEffect")
		ps.Octave = pitchshift
		ps.Parent = soundClone
	end

	if position then
		local new_part = Instance.new("Part")
		new_part.Name = soundClone.Name
		new_part.Anchored = true
		Debris:AddItem(new_part, 10)
		new_part.CanCollide = false
		new_part.Transparency = 1
		new_part.CFrame = CFrame.new(position)
		soundClone.Parent = new_part
		new_part.Parent = game.Workspace
		CollectionService:AddTag(new_part, "TEMPORARY")
		soundMaid:GiveTask(new_part)
	end
	soundClone.Ended:Connect(
		function()
			soundMaid:Destroy()
		end
	)
	soundClone:Play()
	return soundClone
end

if IsServer then
	function SoundUtil.ReplicateSoundForPlayer(plr, sound, options)
		Ropost.publish(
			{
				channel = "SoundUtil",
				topic = "PlaySound",
				player = plr,
				data = {
					sound = sound,
					options = options
				}
			}
		)
	end
	function SoundUtil.ReplicateSoundForPlayersExcept(ignored_plrs, sound, options)
		for _, plr in pairs(Players:GetPlayers()) do
			if not TableUtil.contains(ignored_plrs, plr) then
				SoundUtil.ReplicateSoundForPlayer(plr, sound, options)
			end
		end
	end
	function SoundUtil.ReplicateSoundForPlayersOnly(only_plrs, sound, options)
		for _, plr in pairs(Players:GetPlayers()) do
			if TableUtil.contains(only_plrs, plr) then
				SoundUtil.ReplicateSoundForPlayer(plr, sound, options)
			end
		end
	end
	function SoundUtil.ReplicateSoundForPlayers(sound, options)
		for _, plr in pairs(Players:GetPlayers()) do
			SoundUtil.ReplicateSoundForPlayer(plr, sound, options)
		end
	end
end

return SoundUtil
