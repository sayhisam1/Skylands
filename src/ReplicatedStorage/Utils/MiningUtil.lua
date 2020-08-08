local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Enums = require(ReplicatedStorage.Enums)

local OreBinder = require(ReplicatedStorage.OreBinder)
local module = {}


function module.GetTargetOre(origin, dist)
    assert(RunService:IsClient(), "Can only call on client!")
	local mouse = game.Players.LocalPlayer:GetMouse()
	local raycast_params = RaycastParams.new()
	raycast_params.FilterDescendantsInstances = CollectionService:GetTagged(Enums.Tags.Ore)
	raycast_params.FilterType = Enum.RaycastFilterType.Whitelist

	local mouseray = mouse.UnitRay
	local raycast_results = game.Workspace:Raycast(mouseray.Origin, mouseray.Direction*200, raycast_params)
    local instance = (raycast_results and raycast_results.Instance)
    if instance then
        local ore = OreBinder:LookupInstance(instance)
        if ore and (ore:GetCFrame().Position - origin).Magnitude <= dist or dist == math.huge then
            return ore
        end
    end
end

return module