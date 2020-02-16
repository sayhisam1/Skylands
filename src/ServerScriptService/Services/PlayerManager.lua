--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ManagerServiceObject"):New(script.Name, "Player")
local DEPENDENCIES = {"DataStoreService", "EffectsService", "TeamManager"}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

--CONSTANTS--
local PLAYER_DATA_SAVE_INTERVAL = 180 -- saves all player data every this number of seconds (spaced out by a second in between saves)

-- Maintains a list of PlayerObjects for each player and npc/bot in the game
local PlayerObject = require("PlayerObject")
local Maid = require("Maid").new()
local NetworkChannel = require("NetworkChannel")
local Players = game:GetService("Players")

local event = nil
local PlayerNetworkChannel = nil

local CharactersDir = nil

local HttpService = game:GetService("HttpService")
local _lastSaveUUID = ""
function Service:Load()
    Players.CharacterAutoLoads = false
    local DEFAULT_TEAM = _G.Services.TeamManager:GetDefaultTeam()
    CharactersDir = workspace:FindFirstChild("Characters")
    if not CharactersDir then
        CharactersDir = Instance.new("Folder")
        CharactersDir.Name = "Characters"
        CharactersDir.Parent = workspace
    end

    for _, plr in pairs(Players:GetPlayers()) do
        self:AddObject(PlayerObject:New(plr))
    end

    Maid:GiveTask(
        Players.PlayerAdded:Connect(
            function(plr)
                self:AddObject(PlayerObject:New(plr))
                DEFAULT_TEAM:AddMember(self:GetPlayerByReference(plr))
            end
        )
    )

    Maid:GiveTask(
        Players.PlayerRemoving:Connect(
            function(plr)
                local obj = self:GetPlayerByReference(plr)
                if obj then
                    local team = obj:GetTeam()
                    if team then
                        team:RemoveMember(obj)
                    end
                end
                self:RemoveObjectById(plr.UserId)
            end
        )
    )

    _lastSaveUUID = HttpService:GenerateGUID(false)
    -- Automatically save player data every X seconds
    coroutine.wrap(
        function()
            local uuid = _lastSaveUUID
            while (wait(PLAYER_DATA_SAVE_INTERVAL) and uuid == _lastSaveUUID and self._loaded) do
                local players = self:GetPlayers()
                for _, player in pairs(players) do
                    if not player.IsBot then
                        player:SaveData()
                        wait(.1)
                    end
                end
            end
        end
    )
    event = Instance.new("RemoteEvent")
    event.Name = "PlayerEvent"
    event.Parent = game.ReplicatedStorage.Remote

    PlayerNetworkChannel = NetworkChannel:New("Player", event)

    Maid:GiveTask(PlayerNetworkChannel)

    --- Bind network connections to player requests ---

    -- When a player requests a character --
    Maid:GiveTask(
        PlayerNetworkChannel:Subscribe(
            "RequestCharacter",
            function(plr, ...)
                local obj = self:GetPlayerByReference(plr)
                if obj and obj:GetCharacter() == nil then
                    obj:LoadCharacter()
                end
            end
        )
    )
end

function Service:Unload()
    for i, v in pairs(self:GetObjects()) do
        self:RemoveObject(v)
    end
    Maid:Destroy()
    event:Destroy()
    event = nil
end

function Service:GetCharactersDir()
    return CharactersDir
end
function Service:GetPlayerByReference(reference)
    assert(type(reference) == "userdata", "Invalid reference!")
    return self:GetObjectById(tostring(reference.UserId))
end

function Service:GetPlayerByCharacter(char)
    print("Getting player by ", char:GetFullName())
    for i, v in pairs(self:GetObjects()) do
        local dd = require("DataDump")
        print(dd:dd(v:GetReference()))
        if v:GetCharacter() == char then
            return v
        end
    end
end

function Service:RemovePlayerByReference(reference)
    self:RemovePlayerById(tostring(reference.UserId))
end

function Service:GetPlayerByCharacter(char)
    assert(type(char) == "userdata", "Character is not valid!")
    for i, v in pairs(self:GetObjects()) do
        if v:GetCharacter() == char then
            return v
        end
    end
    return nil
end

function Service:GetNonBotPlayers()
    local plrs = {}
    for idx, plr in pairs(self:GetPlayers()) do
        if (not plr.IsBot) then
            plrs[idx] = plr
        end
    end
    return plrs
end
-- returns network channel responsible for communicating directly with clients
function Service:GetPlayerNetworkChannel()
    return PlayerNetworkChannel
end

return Service
