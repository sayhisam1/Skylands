local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"SettingsController", "ClientPlayerData"}
Service:AddDependencies(DEPENDENCIES)

local SoundService = game:GetService("SoundService")
local Stack = require(ReplicatedStorage.Objects.Shared.Stack)

local musicStack = Stack.new()
local musicRegistry = {}

local MUSIC_SOUND_GROUP = Instance.new("SoundGroup")
MUSIC_SOUND_GROUP.Name = "MusicGroup"
MUSIC_SOUND_GROUP.Parent = SoundService
MUSIC_SOUND_GROUP.Volume = 1

function Service:Load()
    local maid = self._maid
    local default_music = SoundService:WaitForChild("Music"):GetChildren()
    maid:GiveTask(
        function()
            while musicStack:GetSize() > 0 do
                self:PopMusic()
            end
        end
    )
    for i, v in ipairs(default_music) do
        local music = self:_lookupMusic(v)
        maid:GiveTask(
            music.Ended:Connect(
                function()
                    self:Log(3, "Playing next music track")
                    if musicStack:GetSize() <= 1 then
                        self:PopMusic()
                        local next_music_idx = (i % #default_music) + 1
                        self:PushMusic(default_music[next_music_idx])
                    end
                end
            )
        )
    end
    self:PushMusic(default_music[1])

    local ClientPlayerData = self.Services.ClientPlayerData
    local settingStore = ClientPlayerData:GetStore("Settings")
    local init = settingStore:getState()
    if init then
        init = init["Music"]
        if init then
            MUSIC_SOUND_GROUP.Volume = 1
        else
            MUSIC_SOUND_GROUP.Volume = 0
        end
    end

    settingStore.changed:connect(
        function(new)
            local music = new["Music"]
            if music then
                MUSIC_SOUND_GROUP.Volume = 1
            else
                MUSIC_SOUND_GROUP.Volume = 0
            end
        end
    )
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:_lookupMusic(music)
    if not musicRegistry[music] then
        local newMusic = music:Clone()
        newMusic.SoundGroup = MUSIC_SOUND_GROUP
        newMusic.Parent = SoundService
        musicRegistry[music] = newMusic
    end
    return musicRegistry[music]
end

function Service:PushMusic(music)
    self:PauseMusic()
    music = self:_lookupMusic(music)
    musicStack:Push(music)
    music:Resume()
    return music
end

function Service:PauseMusic()
    local currMusic = musicStack:Peek()
    if currMusic then
        currMusic:Pause()
    end
end

function Service:PopMusic()
    self:PauseMusic()
    musicStack:Pop()
    if musicStack:GetSize() > 0 then
        musicStack:Peek():Resume()
    end
end

return Service
