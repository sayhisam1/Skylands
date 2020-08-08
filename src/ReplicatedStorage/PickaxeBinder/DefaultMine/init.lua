local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

return function(tool)
	if IsClient then
		return require(script.ClientMine)(tool)
	else
		return require(script.ServerMine)(tool)
	end
	error("EDGECASE SOMETHING IDK")
end