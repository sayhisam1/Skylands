local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local MarketplaceHandler = Services.MarketplaceHandler
local PlayerData = Services.PlayerData
local Boosts = Services.Boosts
local boostIds = {
    [1087647721] = {
        Category = "Gold",
        Time = 60,
        Muiltiplier = 2,
    }, --2x Coins 1 Hour Boost 	55 	Edit
    [1092140554] = {
        Category = "Gold",
        Time = 120,
        Muiltiplier = 2,
    }, 	--2x Coins 2 Hour Boost 	89 	Edit
    [1092140921] = {
        Category = "Gold",
        Time = 300,
        Muiltiplier = 2,
    }, 	--2x Coins 5 Hour Boost 	200 	Edit

    [1092144094] = {
        Category = "Gems",
        Time = 60,
        Muiltiplier = 2,
    }, --2x Gems 1 Hour Boost 	49 	Edit
    [1092144226] = {
        Category = "Gems",
        Time = 120,
        Muiltiplier = 2,
    }, --2x Gems 2 Hour Boost 	89 	Edit
    [1092144319] = {
        Category = "Gems",
        Time = 300,
        Muiltiplier = 2,
    }, --2x Gems 5 Hour Boost 	200 	Edit

    [1087647241] = {
        Category = "Speed",
        Time = 60,
        Muiltiplier = 2,
    }, -- Mine Speed 1 Hour Boost 	59 	Edit
    [1087647304] = {
        Category = "Speed",
        Time = 120,
        Muiltiplier = 2,
    }, -- Mine Speed 2 Hour Boost
    [1092159950] = {
        Category = "Speed",
        Time = 300,
        Muiltiplier = 2,
    }, -- Mine Speed 5 Hour Boost 	220 	Edit

    [1092162464] = {
        Category = "Damage",
        Time =  60,
        Muiltiplier = 2,
    }, 	--3x Damage 1 hour 	59 	Edit
    [1092162569] = {
        Category = "Damage",
        Time =  120,
        Muiltiplier = 2,
    }, 	--3x Damage 2 Hour Boost 	99 	Edit
    [1092162713] = {
        Category = "Damage",
        Time =  300,
        Muiltiplier = 2,
    }, 	--3x Damage 5 Hour Boost
}
-- 1087647490 	10 Random 30 min boosts 	399 	Edit



-- 1087647280 	2x Pickaxe speed 30 min boost 	49 	Edit
-- 1087647449 	3 Random Boosts 30 min 	99 	Edit



for id, boost_data in pairs(boostIds) do
    MarketplaceHandler:RegisterHandler(id, function(plr)
        Boosts:AddBoost(plr, boost_data.Category, boost_data.Time, boost_data.Muiltiplier)
    end)
end

MarketplaceHandler:RegisterHandler(1092243159, function(plr)
    Boosts:AddRandomBoost(plr, 60)
end)
