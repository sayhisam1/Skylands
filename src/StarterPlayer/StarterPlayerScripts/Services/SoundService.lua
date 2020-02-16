--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"EffectsService"}
local Maid = require("Maid")
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

--local Services = _G.Services
--local EffectsService,SignalService

local SoundSettings = {
	Ambient = .6,
	Music = .7,
	SoundFX = 1,
	Gui = 1,
	Master = 1
}
local CurrentMusic = nil
local Sounds = {}
local Playing = {}

local AssetsDir
local SoundsDir
function Service:Load()
	AssetsDir = ReplicatedStorage:FindFirstChild("Assets")
	SoundsDir = AssetsDir:FindFirstChild("Sounds")
	if not SoundsDir then
		SoundsDir = Instance.new("Folder")
		SoundsDir.Parent = AssetsDir
		SoundsDir.Name = "Sounds"
	end
	for _, sound_group in pairs(SoundsDir:GetChildren()) do
		local group_name = sound_group.Name
		for _, sound in pairs(sound_group:GetChildren()) do
			Sounds[sound.Name] = {
				SoundObj = sound,
				Group = group_name,
				InitialVolume = sound.Volume,
				InitialTimePosition = sound.TimePosition
			}
		end
	end
end
function Service:Unload()
	for key, sound_info in pairs(Sounds) do
		sound_info.SoundObj:Stop()
		Sounds[key] = nil
	end
end

local ActiveMusic = {}

function Service:StopMusic(name)
	if (ActiveMusic[name]) then
		local s = ActiveMusic[name]
		ActiveMusic[name] = nil
		for i = s.SoundObj.Volume, 0, -.05 do
			wait()
			s.SoundObj.Volume = i
		end
		s.SoundObj:Stop()
	end
end

function Service:PlayMusic(name)
	self:StopMusic(name)
	ActiveMusic[name] = self:PlaySound(name)
	for i = 0, ActiveMusic[name].SoundObj.Volume, .05 do
		ActiveMusic[name].SoundObj.Volume = i
	end
end
function Service:PlaySound(sound, options)
	options = options or {}
	assert(type(options) == 'table', "Invalid options specified!")
	if type(sound) == 'string' then
		assert(Sounds[sound], "Tried to play unkown sound "..tostring(sound))
		sound = Sounds[sound].SoundObj
	end
	assert(sound:IsA("Sound"),"Tried to play unkown sound "..tostring(sound))
	local soundClone = sound:Clone()
	game.Debris:AddItem(soundClone, 10)

	-- sound.SoundObj.Volume = sound.InitialVolume * (SoundSettings[sound.Group] or 1) * SoundSettings["Master"]
	-- Mask out extra options
	local position = options.Position
	options.Position = nil

	local pitchshift = options.PitchShift
	options.pitchshift = nil

	for option,value in pairs(options) do
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
		new_part.Anchored = true
		game.Debris:AddItem(new_part, 10)
		new_part.CanCollide = false
		new_part.Transparency = 1
		new_part.CFrame = CFrame.new(position)
		soundClone.Parent = new_part
		new_part.Parent = _G.Services.EffectsService:GetLocalEffectsDir()
		soundMaid:GiveTask(new_part)
	end
	soundClone.Ended:Connect(function() soundMaid:Destroy() end)
	soundClone:Play()
	return soundClone
end

function Service:StopSound(sound_name)
	local sound = Sounds[sound_name]
	if (sound) then
		sound.SoundObj:Stop()
	end
end

return Service
