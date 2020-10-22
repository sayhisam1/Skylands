local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

require(ReplicatedStorage.Lib.TestEZ).TestBootstrap:run({
    ServerScriptService
})