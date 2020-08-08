-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local Rodux = require(ReplicatedStorage.Lib.Rodux)

function Service:Load()
    local maid = self._maid
    local server_comm_channel = self:GetServerNetworkChannel("PlayerData")

    self._stores = {}
    maid:GiveTask(
        server_comm_channel:Subscribe(
            "RESPONSE",
            function(key, response)
                self:Log(1, "Servicing RESPONSE for key", key, "of type", response.type)
                local store = self:GetStore(key)
                store:dispatch(response)
            end
        )
    )

    server_comm_channel:Publish("GET")
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:GetStore(key)
    if not self._stores[key] then
        self._stores[key] =
            Rodux.Store.new(
            function(currentState, action)
                if action.type == "UpdateValue" then
                    return action.Value
                end
            end
        )
    end
    self:Log(1, "Getting store for", key, self._stores[key]:getState())
    return self._stores[key]
end

function Service:FlushCache()
    local server_comm_channel = self:GetServerNetworkChannel("PlayerData")
    server_comm_channel:Publish("GET")
end

return Service
