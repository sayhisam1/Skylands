local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local FabricLib = require(ReplicatedStorage.Lib.Fabric)
local fabric = FabricLib.Fabric.new("game")
FabricLib.useReplication(fabric)
FabricLib.useTags(fabric)


local components = ReplicatedStorage.Components:GetChildren()
if RunService:IsServer() then
    local ServerScriptService = game:GetService("ServerScriptService")
    components = TableUtil.merge(components, ServerScriptService.ServerComponents:GetChildren())
end
if RunService:IsClient() then
    local LocalPlayer = game.Players.LocalPlayer
    local PlayerScripts = LocalPlayer.PlayerScripts
    components = TableUtil.merge(components, PlayerScripts.ClientComponents:GetChildren())
end

for _, v in pairs(components) do
    if not v.Name:match(".spec") then
        fabric:registerComponent(require(v)(fabric))
    end
end

return fabric
