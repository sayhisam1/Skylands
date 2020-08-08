local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DEBUGMODE = RunService:IsStudio()

local SERVICE_DIR = ServerScriptService:WaitForChild("Services")
local ServiceLoader = require(ReplicatedStorage.Objects.Shared.Services.ServiceLoader).new(SERVICE_DIR)

_G.Services = ServiceLoader.ServiceTable
_G.Clock = require(ReplicatedStorage.Objects.Shared.Clock)

ServiceLoader:PrefetchServices()
ServiceLoader:LoadAllServices()

local GameLoaded = Instance.new("BoolValue")
GameLoaded.Name = "GameLoaded"
GameLoaded.Value = true
GameLoaded.Parent = ReplicatedStorage

if DEBUGMODE then
    print("RUNNING TESTS")
    local TestEZ = require(ReplicatedStorage.Lib.TestEZ)
    local Tests = ReplicatedStorage:WaitForChild("Tests")
    TestEZ.TestBootstrap:run(Tests:GetChildren())
end