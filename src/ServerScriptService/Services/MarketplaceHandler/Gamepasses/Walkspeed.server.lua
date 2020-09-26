local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local StarterPlayer = game:GetService("StarterPlayer")


local WALKSPEED = StarterPlayer.CharacterWalkSpeed * 2
local gamepassId = 11685537

local function setupPlayer(plr)
    plr.CharacterAdded:Connect(function()
        local char = plr.Character
        local hum = char:FindFirstChild("Humanoid")
        hum.WalkSpeed = WALKSPEED
    end)
    if plr.Character then
        local char = plr.Character
        local hum = char:FindFirstChild("Humanoid")
        hum.WalkSpeed = WALKSPEED
    end
end

Players.PlayerAdded:Connect(function(plr)
	local hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
	if hasPass then
        setupPlayer(plr)
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, purchasedPassID, purchaseSuccess)
	if purchaseSuccess == true and purchasedPassID == gamepassId then
        setupPlayer(player)
	end
end)
