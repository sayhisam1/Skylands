local ReplicatedStorage = game:GetService("ReplicatedStorage")
local WaitForChildPromise = require(ReplicatedStorage.Objects.Promises.WaitForChildPromise)
local Player = game:GetService("Players").LocalPlayer

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
end)
