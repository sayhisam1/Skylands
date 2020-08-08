local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local Map = Services.Map

local BLOCK_SIZE = 7
return function(context, depth)
	local plr = context.Executor
	local pos = plr.Character.PrimaryPart.Position
	local quarry = Map:GetQuarry()

	for i = 1, depth, 1 do
		local blockPos = pos - Vector3.new(0, i * BLOCK_SIZE, 0)
		local ore = quarry:GetBlockAtAbsoluteCoordinates(blockPos.X, blockPos.Y, blockPos.Z)
		if ore then
			ore:Destroy()
		end
	end

	return string.format("Mined down %d blocks!", depth)
end
