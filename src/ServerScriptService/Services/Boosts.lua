local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)
function Service:Load()
    local function setupPlayer(plr)
        self:Log(2, "Setting up boosts for", plr)
        self:ApplyBoosts(plr)
    end
    self:HookPlayerAction(setupPlayer)

    coroutine.wrap(
        function()
            while wait(60) do
                for _, v in pairs(Players:GetPlayers()) do
                    self:TickBoosts(v, 1)
                end
            end
        end
    )()
end

function Service:ApplyBoosts(plr)
    local PlayerData = self.Services.PlayerData
    local ActiveBoosts = PlayerData:GetStore(plr, "ActiveBoosts")
    for category, boost in pairs(ActiveBoosts:getState()) do
        local boost_id = category .. "_BOOST"
        if boost.RemainingTime > 0 then
            Multipliers.AddPlayerMultiplier(plr, category, boost.Multiplier, category .. "_BOOST")
        else
            Multipliers.RemovePlayerMultiplier(plr, boost_id)
        end
    end
end

function Service:TickBoosts(plr, time)
    local PlayerData = self.Services.PlayerData
    local ActiveBoosts = PlayerData:GetStore(plr, "ActiveBoosts")

    for category, boost in pairs(ActiveBoosts:getState()) do
        ActiveBoosts:dispatch(
            {
                Category = category,
                type = "ReduceBoostTime",
                Time = time
            }
        )
    end

    self:ApplyBoosts(plr)
end

function Service:AddBoost(plr, category, time, mult)
    self:Log(3, "Adding boost", plr, category, time, mult)
    local PlayerData = self.Services.PlayerData
    local ActiveBoosts = PlayerData:GetStore(plr, "ActiveBoosts")
    ActiveBoosts:dispatch(
        {
            type = "AddBoostTime",
            Category = category,
            Time = time,
            Multiplier = mult
        }
    )

    self:ApplyBoosts(plr)
end

function Service:AddRandomBoost(plr, time)
    local choices = {
        {
            Category = "Gold",
            Multiplier = 2
        },
        {
            Category = "Gems",
            Multiplier = 2
        },
        {
            Category = "Speed",
            Multiplier = 2
        },
        {
            Category = "Damage",
            Multiplier = 3
        }
    }

    local rand = choices[math.random(#choices)]
    rand.Time = time
    rand.type = "AddBoostTime"
    local PlayerData = self.Services.PlayerData
    local ActiveBoosts = PlayerData:GetStore(plr, "ActiveBoosts")
    ActiveBoosts:dispatch(rand)
    self:ApplyBoosts(plr)
end

return Service
