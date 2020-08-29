local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local SoundService = game:GetService("SoundService")
local Stack = require(ReplicatedStorage.Objects.Shared.Stack)

local musicStack = Stack.new()
local musicRegistry = {}
function Service:Load()
    local maid = self._maid
    local default_music = SoundService.Music:GetChildren()
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
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:_lookupMusic(music)
    if not musicRegistry[music] then
        local newMusic = music:Clone()
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
