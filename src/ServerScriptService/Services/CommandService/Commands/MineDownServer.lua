local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OreBinder = require(ReplicatedStorage.OreBinder)

local BLOCK_SIZE = 7
return function(context, depth)
	local plr = context.Executor
	local pos = plr.Character.PrimaryPart.Position

	coroutine.wrap(
		function()
			for i = 1, depth, 1 do
				local blockPos = pos - Vector3.new(0, i * BLOCK_SIZE, 0)
				local ore = OreBinder:GetNearestOreNeighbor(blockPos)
				if ore then
					ore:Destroy()
				end
			end
		end
	)()

	return string.format("Mined down %d blocks!", depth)
end
