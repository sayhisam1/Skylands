local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local MarketplaceHandler = Services.MarketplaceHandler
local RunService = game:GetService("RunService")

local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local DevproductBuyGui = setmetatable({}, InstanceWrapper)

DevproductBuyGui.__index = DevproductBuyGui
DevproductBuyGui.ClassName = script.Name

function DevproductBuyGui.new(instance)
    assert(type(instance) == "userdata", "Invalid DevproductBuyGui!")
    local self = setmetatable(InstanceWrapper.new(instance), DevproductBuyGui)

    assert(self:GetAttribute("CalculateValue"), "No calc. val "..instance:GetFullName())
    local CalculateValue = require(self:GetAttribute("CalculateValue"))

    if RunService:IsClient() then
        local AssetId = self:GetAttribute("AssetId")
        local button = self:FindFirstChild("Button")
        button.MouseButton1Click:Connect(function()
            MarketplaceService:PromptProductPurchase(game.Players.LocalPlayer, tonumber(AssetId), false)
        end)
        local changedEv = CalculateValue.GetChangedSignal()
        changedEv.connect(changedEv, function()
            self:Render(CalculateValue.Calculate() * self:GetAttribute("BaseValue"))
        end)
        self:Render(CalculateValue.Calculate() * self:GetAttribute("BaseValue"))
    elseif RunService:IsServer() then
        local PlayerData = Services.PlayerData
        MarketplaceHandler:RegisterHandler(self:GetAttribute("AssetId"), function(plr)
            local store = PlayerData:GetStore(plr, self:GetAttribute("Currency"))
            store:dispatch({
                type="Increment",
                Amount=CalculateValue.Calculate(plr) * self:GetAttribute("BaseValue")
            })
            return "Redeemed! Added 1000 Gold!"
        end)
    end
    return self
end

function DevproductBuyGui:Render(amt)
    local amnt = self:FindFirstChild("Amount"):WaitForChild("Amount")
    amnt.Text = NumberToStr(amt)
end
return DevproductBuyGui
