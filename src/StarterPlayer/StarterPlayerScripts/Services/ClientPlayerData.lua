-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local Rodux = require(ReplicatedStorage.Lib.Rodux)

local initialized = {}
function Service:Load()
    local maid = self._maid
    local server_comm_channel = self:GetServerNetworkChannel("PlayerData")

    self._stores = {}
    local dataReceived = false
    maid:GiveTask(
        server_comm_channel:Subscribe(
            "RESPONSE",
            function(key, response)
                dataReceived = true
                self:Log(1, "Servicing RESPONSE for key", key, "of type", response.type)
                local store = self:InitializeStore(key)
                store:dispatch(response)
                initialized[key] = store
            end
        )
    )

    local currId = self:GetLoadId()
    coroutine.wrap(function()
        while not dataReceived and self:GetLoadId() == currId do
            server_comm_channel:Publish("GET")
            wait(5)
        end
    end)()
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:InitializeStore(key)
    if not self._stores[key] then
        self._stores[key] =
            Rodux.Store.new(
            function(currentState, action)
                self:Log(1, "Update store for", key, action.Value)
                if action.type == "UpdateValue" then
                    return action.Value
                end
            end
        )
    end
    return self._stores[key]
end

function Service:GetStore(key)
    self:Log(1, "Getting store for", key)
    while not initialized[key] do
        wait()
    end
    return initialized[key]
end

function Service:FlushCache()
    local server_comm_channel = self:GetServerNetworkChannel("PlayerData")
    server_comm_channel:Publish("GET")
end

return Service
