-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Services = require(ReplicatedStorage.Services)
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()


local module = {}

if IsServer then
    local PlayerData = Services.PlayerData
    function module.GetPlayerMultiplier(player, category)
        local store = PlayerData:GetStore(player, "ActiveMultipliers")
        local state = store:getState()
        return state[category] and state[category]["TOTAL_MULTIPLIER"] or 1
    end

    function module.AddPlayerMultiplier(player, category, multiplier)
        local store = PlayerData:GetStore(player, "ActiveMultipliers")
        local id = HttpService:GenerateGUID(false)
        store:dispatch({
            type="AddMultiplier",
            Id = id,
            Category = category,
            Multiplier = multiplier,
        })
        return function()
            store:dispatch({
                type="RemoveMultiplier",
                Id = id
            })
        end
    end
end

if IsClient then
    local ClientPlayerData = Services.ClientPlayerData
    function module.GetMultiplier(category)
        local store = ClientPlayerData:GetStore("ActiveMultipliers")
        local state = store:getState()
        return state[category] and state[category]["TOTAL_MULTIPLIER"] or 1
    end
end

return module