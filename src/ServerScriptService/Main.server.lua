local RunService = game:GetService("RunService")
local DEBUGMODE = RunService:IsStudio()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local ServerScriptService = game:GetService("ServerScriptService")
local SERVICE_DIR = ServerScriptService:WaitForChild("Services")
local ServiceLoader = require("ServiceLoaderObject"):New(SERVICE_DIR)

_G.Services = ServiceLoader.ServiceTable
_G.Clock = require("Clock")

-- local TEST_ITEM = ReplicatedStorage.Assets.Tools["Pickaxe"]
-- TEST_ITEM:Clone().Parent = game.StarterPack
ServiceLoader:PrefetchServices()
ServiceLoader:LoadAllServices()

if DEBUGMODE then
    local TestRunner = require(ReplicatedStorage.Tests.TestRunner)
    TestRunner:RunAll()
end

-- 
-- local BotPlayerFactory = require("ServerBotPlayer")
-- local b = BotPlayerFactory:New("bot")

-- b:LoadCharacter()

-- local AIController = require("TestNPCAI"):New(b)
-- AIController:Start()
