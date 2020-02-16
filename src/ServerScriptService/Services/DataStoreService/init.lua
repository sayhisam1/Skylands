--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)

local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------
local ServerScriptService = game:GetService("ServerScriptService")
local DataStore2 = require(script.DataStore2)
local Pickler = require("Pickler")
--SETTINGS--
local ENABLED = true

--CONSTANTS--
local DATA_STORE_KEY_TABLE_NAME = "PlayerDataUpdateKeys"
local DATA_STORE_DATA_TABLE_NAME = "PlayerData"

function Service:Load()
end

function Service:RetrieveData(plr_obj)
    local ref = plr_obj:GetReference()
    assert(type(ref) == 'userdata', "Invalid reference!")

    local data = (not ENABLED and {}) or DataStore2(DATA_STORE_DATA_TABLE_NAME, ref):Get()
    return Pickler:Unpickle(data)
end


function Service:SaveData(plr_obj, data)
    local ref = plr_obj:GetReference()
    assert(type(ref) == 'userdata', "Invalid reference!")
    if not ENABLED then
        return
    end

    local pickled_data = data
    return DataStore2(DATA_STORE_DATA_TABLE_NAME, ref):Set(pickled_data)
end

return Service
