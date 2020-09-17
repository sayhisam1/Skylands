local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerScriptService = game:GetService("ServerScriptService")

local DEBUGMODE = RunService:IsStudio()

local SERVICE_DIR = ServerScriptService:WaitForChild("Services")
local ServiceLoader = require(ReplicatedStorage.Objects.Shared.Services.ServiceLoader).new(SERVICE_DIR)

_G.Services = ServiceLoader.ServiceTable

ServiceLoader:PrefetchServices()
ServiceLoader:LoadAllServices()

local GameLoaded = Instance.new("BoolValue")
GameLoaded.Name = "GameLoaded"
GameLoaded.Value = true
GameLoaded.Parent = ReplicatedStorage

if DEBUGMODE then
    print("RUNNING TESTS")
    local TestEZ = require(ReplicatedStorage.Lib.TestEZ)
    local IGNORED_TEST_DIRS = {ReplicatedStorage.Lib}
    local tests = {}
    for _, v in pairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:match(".spec") then
            local toTest = true
            for _, ignored in pairs(IGNORED_TEST_DIRS) do
                if v:IsDescendantOf(ignored) then
                    toTest = false
                end
            end
            if toTest then
                tests[#tests + 1] = v
            end
        end
    end
    TestEZ.TestBootstrap:run(tests)
end
