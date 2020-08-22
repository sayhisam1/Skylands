if not game:IsLoaded() then
    game.Loaded:Wait()
end

local RunService = game:GetService("RunService")
local DEBUGMODE = RunService:IsStudio()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("GameLoaded")

local Player = game:GetService("Players").LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")
local SERVICE_DIR = PlayerScripts:WaitForChild("Services")
local ServiceLoader = require(ReplicatedStorage.Objects.Shared.Services.ServiceLoader).new(SERVICE_DIR)
_G.Services = ServiceLoader.ServiceTable

ServiceLoader:PrefetchServices()
ServiceLoader:LoadAllServices()

-- if DEBUGMODE then
--     local TestRunner = require(ReplicatedStorage.Tests.TestRunner)
--     TestRunner:RunAll()
-- end
