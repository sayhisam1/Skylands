local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local OreBinder = require(ReplicatedStorage.OreBinder)
local SPAWNED_ORES = OreBinder:GetOresDirectory()

local module = {}

local raycast_params = RaycastParams.new()
raycast_params.FilterDescendantsInstances = {SPAWNED_ORES}
raycast_params.FilterType = Enum.RaycastFilterType.Whitelist
local mouse = game.Players.LocalPlayer:GetMouse()

local ore
RunService.Heartbeat:Connect(
    function()
        local mouseray = mouse.UnitRay
        local raycast_results = game.Workspace:Raycast(mouseray.Origin, mouseray.Direction * 200, raycast_params)
        local instance = (raycast_results and raycast_results.Instance)
        if instance then
            ore = OreBinder:LookupInstance(instance)
        end
    end
)

function module.GetTargetOre(origin, dist)
    assert(RunService:IsClient(), "Can only call on client!")
    if ore and not ore._destroyed and (ore:GetCFrame().Position - origin).Magnitude <= dist or dist == math.huge then
        return ore
    end
end

return module
