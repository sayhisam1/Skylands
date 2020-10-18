local RunService = game:GetService("RunService")

return function(teleporter)
	assert(RunService:IsServer(), "Can only be called on server!")
	local teleporterChannel = teleporter:GetNetworkChannel()
	teleporterChannel:Subscribe(
		"TELEPORT",
		function(plr)
			local canTeleport = teleporter:RunModule("TeleportCheck", plr)
			if canTeleport == nil then
				canTeleport = true
			end
			if canTeleport then
				teleporterChannel:PublishPlayer(plr, "TELEPORTED")
				local target = teleporter:GetAttribute("TeleportTarget")
				if plr.Character then
					plr.Character:MoveTo(target.Position)
				end
			end
		end
	)
end
