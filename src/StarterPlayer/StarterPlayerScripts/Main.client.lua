local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local DEBUGMODE = RunService:IsStudio()

local WaitForChildPromise = require(ReplicatedStorage.Objects.Promises.WaitForChildPromise)
local Player = Players.LocalPlayer

if not game:IsLoaded() then
    game.Loaded:Wait()
end

WaitForChildPromise(Player, "DataLoaded"):andThen(function()
    ReplicatedStorage:WaitForChild("GameLoaded")

    local PlayerScripts = Player:WaitForChild("PlayerScripts")
    local SERVICE_DIR = PlayerScripts:WaitForChild("Services")
    local ServiceLoader = require(ReplicatedStorage.Objects.Shared.Services.ServiceLoader).new(SERVICE_DIR)
    _G.Services = ServiceLoader.ServiceTable

    ServiceLoader:PrefetchServices()
    ServiceLoader:LoadAllServices()

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
end)
