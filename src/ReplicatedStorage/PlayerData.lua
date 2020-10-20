local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local DataStore2 = require(ReplicatedStorage.Lib.DataStore2)
local Promise = require(ReplicatedStorage.Lib.Promise)
local Rodux = require(ReplicatedStorage.Lib.Rodux)
local Ropost = require(ReplicatedStorage.Lib.Ropost)

local KEYS =
    TableUtil.transform(
    ReplicatedStorage.DataKeys:GetChildren(),
    function(_, v)
        return v.Name, require(v).Keys
    end
)
KEYS = TableUtil.mergeDict(unpack(TableUtil.values(KEYS)))
local DATASTORE_KEYS =
    TableUtil.filter(
    KEYS,
    function(_, v)
        return v.Stateful
    end
)

DataStore2.Combine("TEST_DATA", unpack(TableUtil.keys(DATASTORE_KEYS)))

local module = {}

if RunService:IsServer() then
    local function augmentStatefulStore(player, storeName, store)
        assert(DATASTORE_KEYS[storeName], "Invalid stateful store!")
        local defaultValue = DATASTORE_KEYS[storeName].DEFAULT_VALUE
        local ds = DataStore2(storeName, player)
        local ok, initialState

        repeat
            ok, initialState =
                pcall(
                function()
                    if type(defaultValue) == "table" then
                        initialState = ds:GetTable(defaultValue)
                    else
                        initialState = ds:Get(defaultValue)
                    end
                end
            )
        until ok or (wait(10) and false)
        store.changed:connect(
            function(new)
                ds:Set(new)
            end
        )
        store:dispatch({type = "Set", value = initialState or defaultValue})
        return store
    end

    local function augmentReplicatedStore(player, storeName, store)
        local function publish(data)
            Ropost.publish(
                {
                    player = player,
                    channel = "PlayerData",
                    topic = string.format("%s.%s", storeName, "Sync"),
                    data = data
                }
            )
        end
        store.changed:connect(
            function(new)
                publish(new)
            end
        )
        publish(store:getState())
    end

    local cachedStorePromises = {}
    function module.GetPlayerStore(player, storeName)
        assert(KEYS[storeName], "Invalid store name!")
        if not cachedStorePromises[player] then
            cachedStorePromises[player] = {}
        end
        if not cachedStorePromises[player][storeName] then
            cachedStorePromises[player][storeName] =
                Promise.new(
                function(resolve, _, _)
                    local defaultValue = KEYS[storeName].DEFAULT_VALUE
                    local reducer = KEYS[storeName].Reducer
                    local store = Rodux.Store.new(reducer, defaultValue)
                    if DATASTORE_KEYS[storeName] then
                        augmentStatefulStore(player, storeName, store)
                    end
                    if typeof(player) == "userdata" and player:IsA("Player") then
                        augmentReplicatedStore(player, storeName, store)
                    end
                    resolve(store)
                end
            )
        end
        return cachedStorePromises[player][storeName]
    end

    -- preload data on player join
    Players.PlayerAdded:Connect(
        function(player)
            for storeName, _ in pairs(KEYS) do
                module.GetPlayerStore(player, storeName)
            end
        end
    )

    -- clear data on player leave
    Players.PlayerRemoving:Connect(
        function(player)
            if not cachedStorePromises[player] then
                return
            end
            for storeName, _ in pairs(KEYS) do
                if cachedStorePromises[player][storeName] then
                    cachedStorePromises[player][storeName]:andThen(
                        function(store)
                            store:destruct()
                        end
                    )
                    cachedStorePromises[player][storeName] = nil
                end
            end
            cachedStorePromises[player] = nil
        end
    )

    for storeName, _ in pairs(KEYS) do
        Ropost.subscribe(
            {
                channel = "PlayerData",
                topic = string.format("%s.%s", storeName, "Request"),
                callback = function(_, envelope)
                    local player = envelope.player
                    if not cachedStorePromises[player] then
                        return
                    end
                    if not cachedStorePromises[player][storeName] then
                        return
                    end
                    cachedStorePromises[player][storeName]:andThen(
                        function(store)
                            Ropost.publish(
                                {
                                    channel = "PlayerData",
                                    topic = string.format("%s.%s", storeName, "Request"),
                                    data = store:getState()
                                }
                            )
                        end
                    )
                end
            }
        )
    end
end

if RunService:IsClient() then
    local cachedStores = {}
    for storeName, _ in pairs(KEYS) do
        cachedStores[storeName] =
            Promise.new(
            function(resolve)
                local store =
                    Rodux.Store.new(
                    function(_, action)
                        if action.type == "Sync" then
                            return action.data
                        end
                    end
                )
                local retrieved = false
                Ropost.subscribe(
                    {
                        channel = "PlayerData",
                        topic = string.format("%s.%s", storeName, "Sync"),
                        callback = function(data)
                            store:dispatch(
                                {
                                    type = "Sync",
                                    data = data
                                }
                            )
                            retrieved = true
                        end
                    }
                )
                repeat
                    Ropost.publish(
                        {
                            channel = "PlayerData",
                            topic = string.format("%s.%s", storeName, "Request")
                        }
                    )
                until retrieved or (wait(1) and false)
                resolve(store)
            end
        )
    end
    function module.GetStore(storeName)
        assert(KEYS[storeName], "Invalid store!")
        return cachedStores[storeName]
    end
end

return module
