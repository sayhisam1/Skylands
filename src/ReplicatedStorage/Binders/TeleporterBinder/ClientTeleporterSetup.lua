local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

return function(teleporter)
	assert(RunService:IsClient(), "Can only be called on client!")
	local primaryPart = teleporter:GetInstance().PrimaryPart
	local debounce = false
	primaryPart.Touched:Connect(
		function(part)
			if debounce then
				return
			end
			local char = LocalPlayer.Character
			if not char then
				return
			end
			if part:IsDescendantOf(char) then
				debounce = true
				local re = teleporter:GetNetworkChannel()
				re:Publish("TELEPORT")
				wait(teleporter:GetAttribute("TeleportCooldown") or 3)
				debounce = false
			end
		end
	)
end
