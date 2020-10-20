local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local PICKAXES
if RunService:IsRunning() then
    PICKAXES = require(ReplicatedStorage.Binders:WaitForChild("Pickaxes"))
else
    PICKAXES = require(Workspace:WaitForChild("Pickaxes"))
end

local keys = {}

keys.Pickaxes = {
    Stateful = true,
    DEFAULT_VALUE = {
        BasicPickaxe = {
            Selected = true
        }
    },
    Reducer = function(currentState, action)
        if action.type == "Set" then
            assert(action.value, "Invalid Value!")
            return action.value
        elseif action.type == "AddPickaxe" then
            local assetKey = action.assetKey
            local newState = TableUtil.shallow(currentState)
            newState[assetKey] = {
                Selected = false
            }
            return newState
        elseif action.type == "RemovePickaxe" then
            local assetKey = action.assetKey
            local newState = TableUtil.shallow(currentState)
            newState[assetKey] = nil
            return newState
        end
    end
}

local ret = {}
ret.Keys = keys

function ret.addPickaxe(pickaxe)
    pickaxe = PICKAXES:LookupBase(pickaxe)
    assert(pickaxe, "Invalid pickaxe!")
    return {
        type = "AddPickaxe",
        assetKey = pickaxe.Name
    }
end
function ret.removePickaxe(pickaxe)
    return {
        type = "RemovePickaxe",
        assetKey = pickaxe.Name
    }
end

return ret
