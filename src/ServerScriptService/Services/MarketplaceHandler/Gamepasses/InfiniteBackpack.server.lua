local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local Services = require(ReplicatedStorage.Services)
local PlayerData = Services.PlayerData
local Promise = require(ReplicatedStorage.Lib.Promise)
local AssetFinder = require(ReplicatedStorage.AssetFinder)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local gamepassId = 11685532
local INFINITE_BACKPACK = AssetFinder.FindBackpack("Infinity Pack")

local function setupPlayer(plr)
    local Shop = Services.Shop
    Shop:AddAsset(plr, INFINITE_BACKPACK)
end

local function playerAdded(plr)
    local hasPass = MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId)
    if hasPass then
        setupPlayer(plr)
    else
        -- remove inf backpack from ppl who got it from bug
        local ownedBackpacks = PlayerData:GetStore(plr, "OwnedBackpacks")
        PlayerData:Log(3, "INFINITY BACKPACK", ownedBackpacks:getState())
        if TableUtil.contains(ownedBackpacks:getState(), "Infinity Pack") then
            warn(plr, "removing infinite backpack!")
            ownedBackpacks:dispatch(
                {
                    type = "RemoveItem",
                    Item = "Infinity Pack"
                }
            )

            PlayerData:ResetPlayerDataKey(plr, "SelectedBackpack")
        end
    end
end

for _, v in pairs(Players:GetPlayers()) do
    playerAdded(v)
end
Players.PlayerAdded:Connect(
    function(plr)
        playerAdded(plr)
    end
)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(
    function(player, purchasedPassID, purchaseSuccess)
        if purchaseSuccess == true and purchasedPassID == gamepassId then
            setupPlayer(player)
        end
    end
)

PlayerData:RegisterResetHook(
    "OwnedBackpacks",
    function(plr, store, prev)
        local ownsGamepass =
            Promise.new(
            function(resolve, reject, onCancel)
                return resolve(MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId))
            end
        ):andThen(
            function(hasPack)
                if hasPack then
                    setupPlayer(plr)
                end
            end
        )
    end
)

PlayerData:RegisterResetHook(
    "SelectedBackpack",
    function(plr, store, prev)
        local ownsGamepass =
            Promise.new(
            function(resolve, reject, onCancel)
                return resolve(MarketplaceService:UserOwnsGamePassAsync(plr.UserId, gamepassId))
            end
        ):andThen(
            function(hasPack)
                if hasPack and prev == "Infinity Pack" then
                    store:dispatch(
                        {
                            type = "Set",
                            Value = "Infinity Pack"
                        }
                    )
                end
            end
        )
    end
)
