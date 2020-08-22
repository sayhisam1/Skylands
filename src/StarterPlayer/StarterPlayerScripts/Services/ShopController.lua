local CLOSE_REOPEN_DELAY = 5 -- can't open shop for this much time after close

-- stores player inventories --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"GuiController", "ClientPlayerData"}
Service:AddDependencies(DEPENDENCIES)

local CollectionService = game:GetService("CollectionService")

Service.SHOP_CATEGORIES = {
    Pickaxes = "Pickaxes",
    Backpacks = "Backpacks"
}
local last_close_time = 0

local debounce = false
function Service:Load()
    local shopPart = CollectionService:GetTagged(self.Enums.Tags.ShopPart)[1]
    self._maid:GiveTask(
        shopPart.Touched:Connect(
            function(part)
                if not debounce and tick() - last_close_time > CLOSE_REOPEN_DELAY and part:IsDescendantOf(game.Players.LocalPlayer.Character) then
                    debounce = true
                    self.Services.GuiController:SetGuiGroupVisible(self.Services.GuiController.GUI_GROUPS["Shop"], true)
                    wait(.3)
                    debounce = false
                end
            end
        )
    )
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:ResetLastShopCloseTime()
    last_close_time = tick()
end

function Service:RequestPlayerTeleport()
    local network_channel = self:GetServerNetworkChannel("Shop")
    network_channel:Publish("REQUEST_SHOP_TELEPORT")
end

function Service:TryBuy(instance)
    local network_channel = self:GetServerNetworkChannel("Shop")
    network_channel:Publish("REQUEST_BUY", instance)
end

function Service:TrySelect(instance)
    local network_channel = self:GetServerNetworkChannel("Shop")
    network_channel:Publish("REQUEST_SELECT", instance)
end

return Service
