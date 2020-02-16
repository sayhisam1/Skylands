--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ManagerServiceObject"):New(script.Name, "Team")
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

-- Maintains a list of PlayerObjects for each player and npc/bot in the game
local Team = require("Team")
local Maid = require("Maid").new()

local DEFAULT_TEAM = nil
local DEFAULT_BOT_TEAM = nil

function Service:Load()
    DEFAULT_TEAM = Team:New("DEFAULT", 1)
    DEFAULT_BOT_TEAM = Team:New("DEFAULT_BOT", 2)
    self:AddTeam(DEFAULT_TEAM)
    self:AddTeam(DEFAULT_BOT_TEAM)
end

function Service:Unload()
    self:RemoveAllTeams()
end

function Service:GetDefaultTeam()
    return DEFAULT_TEAM
end

function Service:GetDefaultBotTeam()
    return DEFAULT_BOT_TEAM
end

return Service
