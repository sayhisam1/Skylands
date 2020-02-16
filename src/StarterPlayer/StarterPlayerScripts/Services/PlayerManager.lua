--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ManagerServiceObject"):New(script.Name, "Player")
local DEPENDENCIES = {"TeamManager"}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

-- Maintains a list of PlayerObjects for each player and npc/bot in the game
local PlayerObject = require("PlayerObject")
local Maid = require("Maid").new()

local CharactersDir
function Service:Load()
    CharactersDir = workspace:WaitForChild("Characters")
    local localplayer = game.Players.LocalPlayer
    local network_channel = self:GetNetworkChannel()
    while self:GetPlayerByReference(localplayer) == nil do
        network_channel:Publish("RequestInfo")
        wait(.5)
    end
end

function Service:Unload()
    for i, v in pairs(self:GetObjects()) do
        self:RemoveObject(v)
    end
    Maid:Destroy()
end
function Service:GetCharactersDir()
    return CharactersDir
end
function Service:GetPlayerByReference(reference)
    assert(type(reference) == "userdata", "Invalid reference!")
    return self:GetObjectById(tostring(reference.UserId))
end

function Service:GetPlayerByCharacter(char)
    for i, v in pairs(self:GetObjects()) do
        if v:GetCharacter() == char then
            return v
        end
    end
end

function Service:RemovePlayerByReference(reference)
    self:RemovePlayerById(tostring(reference.UserId))
end

return Service
