-- stores player inventories --

local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local Players = game:GetService("Players")
local DataStore2 = require(ReplicatedStorage.Lib.DataStore2)

local DATA_SAVE_TIMER = 300
local Promise = require(ReplicatedStorage.Lib.Promise)
local Rodux = require(ReplicatedStorage.Lib.Rodux)

local KeysDir = script.Keys
local KEYS = {}
for _, v in pairs(KeysDir:GetChildren()) do
    local req = require(v)
    KEYS[v.Name] = req
end
local DATASTORE_KEYS =
    TableUtil.filter(
    KEYS,
    function(k, v)
        return v.Stateful and v
    end
)

local ORDERED_DATASTORE_KEYS =
    TableUtil.filter(
    KEYS,
    function(k, v)
        return v.Ordered and v
    end
)

DataStore2.Combine("BETA_DATA", unpack(TableUtil.keys(DATASTORE_KEYS)))

local playerData = {}
function Service:Load()
    local maid = self._maid

    -- Setup Client requests
    local network_channel = self:GetNetworkChannel()
    self:Log(1, "Initialized with keys", self.TableUtil.keys(KEYS))
    -- setup endpoints
    maid:GiveTask(
        network_channel:Subscribe(
            "GET",
            function(plr)
                self:Log(1, "Servicing GET request for", plr)
                for key, v in pairs(KEYS) do
                    local store = self:GetStore(plr, key)
                    network_channel:PublishPlayer(
                        plr,
                        "RESPONSE",
                        key,
                        {
                            type = "UpdateValue",
                            Value = store:getState()
                        }
                    )
                end
            end
        )
    )

    self:HookPlayerAction(
        function(plr)
            self:Log(3, "Player joined", plr.Name)
            local promises = {}
            for key, v in pairs(KEYS) do
                promises[#promises + 1] = Promise.new(function(resolve)
                    local store = self:InitializeStore(plr, key)
                    resolve(store)
                end)
            end
            Promise.all(promises):andThen(function()
                local lastVisitTime = self:GetStore(plr, "LastVisitTime")
                lastVisitTime:dispatch(
                    {
                        type = "Set",
                        Value = tick()
                    }
                )
                local DataLoaded = Instance.new("BoolValue")
                DataLoaded.Name = "DataLoaded"
                DataLoaded.Value = true
                DataLoaded.Parent = plr
            end)
            self:UpdateTimePlayed(plr)
        end
    )

    self._maid:GiveTask(
        Players.PlayerRemoving:Connect(
            function(plr)
                self:UpdateTimePlayed(plr)
                self:ClearTimePlayed(plr)
                self:SaveData(plr)
                for _, v in pairs(playerData[plr.UserId]) do
                    v:destruct()
                end
                playerData[plr.UserId] = nil
            end
        )
    )

    local loadId = self:GetLoadId()
    coroutine.wrap(
        function()
            while self:GetLoadId() == loadId and wait(DATA_SAVE_TIMER) do
                for _, plr in pairs(Players:GetPlayers()) do
                    self:UpdateTimePlayed(plr)
                    self:SaveData(plr)
                    wait(1)
                end
            end
        end
    )()
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:SaveData(plr)
    DataStore2.SaveAll(plr)
    local leaderboardHidden = self:GetStore(plr, "LeaderboardHidden"):getState()
    for k, v in pairs(ORDERED_DATASTORE_KEYS) do
        local ds = DataStoreService:GetOrderedDataStore(k)
        local store = self:GetStore(plr, k)
        local val = not leaderboardHidden and store:getState() or v.DEFAULT_VALUE
        self:Log(1, plr, "setordered", k, val)
        ds:SetAsync(plr.UserId, val)
    end
end

function Service:SetLeaderstat(plr, statname, val)
    local leaderstats = plr:FindFirstChild("leaderstats")
    if not leaderstats then
        leaderstats = Instance.new("Folder")
        leaderstats.Name = "leaderstats"
        leaderstats.Parent = plr
    end
    local stat = leaderstats:FindFirstChild(statname)
    if not stat then
        if typeof(val) == "number" then
            stat = Instance.new("NumberValue")
        elseif typeof(val) == "string" then
            stat = Instance.new("StringValue")
        end
        stat.Name = statname
        stat.Parent = leaderstats
    end
    stat.Value = val
end

function Service:InitializeStore(plr, key)
    assert(plr and plr:IsA("Player"), "Not a player!")
    assert(KEYS[key], string.format("%s is not a valid key!", key))
    if not playerData[plr.UserId] then
        playerData[plr.UserId] = {}
    end

    if not playerData[plr.UserId][key] then
        self:Log(3, "Initialize store", plr, key)
        local keyData = KEYS[key]
        local reducer = keyData.Reducer
        local defaultValue = keyData.DEFAULT_VALUE

        local initialState = defaultValue
        if keyData.Stateful then
            local ds = DataStore2(key, plr)
            if type(defaultValue) == "table" then
                initialState = ds:GetTable(defaultValue)
            else
                initialState = ds:Get(defaultValue)
            end
        end

        self:Log(1, plr, "Initial data get for key", key, ":", initialState)

        playerData[plr.UserId][key] = Rodux.Store.new(reducer, initialState)
        playerData[plr.UserId][key]:dispatch(
            {
                type = "Set",
                Value = initialState
            }
        )
        local function updateClient(state)
            local network_channel = self:GetNetworkChannel()
            local action = {
                type = "UpdateValue",
                Value = state
            }
            network_channel:PublishPlayer(plr, "RESPONSE", key, action)
        end

        if not plr:IsA("MockPlayer") then
            self._maid:GiveTask(playerData[plr.UserId][key].changed:connect(
                function(new, old)
                    updateClient(new)
                end
            ))
        end

        if keyData.Stateful then
            local ds = DataStore2(key, plr)
            self._maid:GiveTask(
                playerData[plr.UserId][key].changed:connect(
                    function(new, old)
                        ds:Set(new)
                    end
                )
            )
        end

        if keyData.Leaderstat then
            self._maid:GiveTask(
                playerData[plr.UserId][key].changed:connect(
                    function(new, old)
                        if keyData.LeaderstatFunction then
                            new = keyData.LeaderstatFunction(new)
                        end
                        self:SetLeaderstat(plr, keyData.LeaderstatName, new)
                    end
                )
            )
        end
    end

    self:Log(1, "Got player data", key, playerData[plr.UserId][key]:getState())
    return playerData[plr.UserId][key]
end

function Service:GetStore(plr, key)
    assert(plr and plr:IsA("Player"), "Not a player!")
    assert(KEYS[key], string.format("%s is not a valid key!", key))
    local promise = Promise.new(function(resolve)
        while not playerData[plr.UserId] do
            RunService.Heartbeat:Wait()
        end
        while not playerData[plr.UserId][key] do
            RunService.Heartbeat:Wait()
        end
        resolve(playerData[plr.UserId][key])
    end)
    return promise:expect()
end

function Service:ResetPlayerDataKey(plr, key)
    assert(plr:IsA("Player"), "Invalid player!")
    assert(KEYS[key], "Invalid key!")
    local store = self:GetStore(plr, key)
    local default_val = KEYS[key].DEFAULT_VALUE
    store:dispatch(
        {
            type = "Set",
            Value = default_val
        }
    )
end

function Service:ResetPlayerData(plr)
    self:Log(3, "Reset player data for", plr)
    for key, data in pairs(KEYS) do
        self:ResetPlayerDataKey(plr, key)
    end
end

local lastTimePlayedUpdate = {}
function Service:UpdateTimePlayed(plr)
    local t = tick()
    if not lastTimePlayedUpdate[plr] then
        lastTimePlayedUpdate[plr] = t
        return
    end
    local diff = math.floor(t - lastTimePlayedUpdate[plr])
    local store = self:GetStore(plr, "TotalTimePlayed")
    store:dispatch({
        type="Increment",
        Amount = diff,
    })
    lastTimePlayedUpdate[plr] = t
end

function Service:ClearTimePlayed(plr)
    lastTimePlayedUpdate[plr] = nil
end
return Service
