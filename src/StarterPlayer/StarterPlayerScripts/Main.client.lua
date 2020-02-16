local RunService = game:GetService("RunService")
local DEBUGMODE = RunService:IsStudio()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local SERVICE_DIR = PlayerScripts:WaitForChild("Services")
local ServiceLoader = require("ServiceLoaderObject"):New(SERVICE_DIR)
_G.Services = ServiceLoader.ServiceTable
_G.Clock = require("Clock")

ServiceLoader:PrefetchServices()
ServiceLoader:LoadAllServices()

if DEBUGMODE then
    local TestRunner = require(ReplicatedStorage.Tests.TestRunner)
    TestRunner:RunAll()
end
