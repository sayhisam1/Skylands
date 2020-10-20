local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local BACKPACKS
if RunService:IsRunning() then
    BACKPACKS = require(ReplicatedStorage.Binders:WaitForChild("Backpacks"))
else
    BACKPACKS = require(Workspace:WaitForChild("Backpacks"))
end

local keys = {}

keys.Backpacks = {
    Stateful = true,
    DEFAULT_VALUE = {
        BasicBackpack = {
            Selected = true
        }
    },
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.value, "Invalid Value!")
            return action.value
        elseif action.type == "AddBackpack" then
            local assetKey = action.assetKey
            local newState = TableUtil.shallow(currentState)
            newState[assetKey] = {
                Selected = false
            }
            return newState
        elseif action.type == "RemoveBackpack" then
            local assetKey = action.assetKey
            local newState = TableUtil.shallow(currentState)
            newState[assetKey] = nil
            return newState
        end
    end
}

keys.BackpackState = {
    Stateful = true,
    DEFAULT_VALUE = {
        Capacity = 0,
        FillCount = 0,
        GoldValue = 0,
    },
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.value, "Invalid Value!")
            return action.value
        elseif action.type == "SetCapacity" then
            assert(action.capacity, "Invalid Capacity!")
            local newState = TableUtil.shallow(currentState)
            newState.Capacity = action.capacity
            return newState
        elseif action.type == "IncrementGoldValue" then
            assert(action.amount, "Invalid Amount!")
            local newState = TableUtil.shallow(currentState)
            newState.GoldValue = math.floor(newState.GoldValue + action.amount)
            return newState
        elseif action.type == "DecrementGoldValue" then
            assert(action.amount, "Invalid Amount!")
            local newState = TableUtil.shallow(currentState)
            newState.GoldValue = math.max(0, newState.GoldValue - action.amount)
            return newState
        elseif action.type == "IncrementFillCount" then
            assert(action.amount, "Invalid Amount!")
            local newState = TableUtil.shallow(currentState)
            newState.FillCount = math.floor(newState.FillCount + action.amount)
            return newState
        elseif action.type == "DecrementFillCount" then
            assert(action.amount, "Invalid Amount!")
            local newState = TableUtil.shallow(currentState)
            newState.FillCount = math.max(0, newState.FillCount - action.amount)
            return newState
        end
    end
}

local ret = {}
ret.Keys = keys

function ret.addBackpack(backpack)
    backpack = BACKPACKS:LookupBase(backpack)
    assert(backpack, "Invalid backpack!")
    return {
        type = "AddBackpack",
        assetKey = backpack.Name
    }
end
function ret.removeBackpack(backpack)
    return {
        type = "RemoveBackpack",
        assetKey = backpack.Name
    }
end

return ret
