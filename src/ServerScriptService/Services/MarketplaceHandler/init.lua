local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local PRODUCTS = {}


TableUtil.foreachi(script.Products:GetChildren(), function(i, v)
    PRODUCTS[v.Name] = require(v)
end)

TableUtil.foreachi(script.Gamepasses:GetChildren(), function(i, v)
    PRODUCTS[v.Name] = require(v)
end)

function Service:Load()
    MarketplaceService.ProcessReceipt = function(receiptInfo)
        self:Log(3, "Process receipt", receiptInfo)
        local playerId = receiptInfo.PlayerId
        local productId = receiptInfo.ProductId
        if not playerId or not productId then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        local plr = Players:GetPlayerByUserId(playerId)
        if not plr then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        local productHandler = PRODUCTS[tostring(productId)]
        if not productHandler then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
       local stat, err = pcall(function()
            productHandler(plr)
        end)
        if not stat then
            return Enum.ProductPurchaseDecision.NotProcessedYet
        end
        return Enum.ProductPurchaseDecision.PurchaseGranted
    end
end

function Service:RegisterHandler(productId, func)
    productId = tostring(productId)
    assert(not PRODUCTS[productId], "Handler already exists!")
    self:Log(3, "Register handler", productId)
    PRODUCTS[productId] = func
end

return Service