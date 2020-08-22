--------------------------------
--// NETWORK CHANNEL OBJECT \\--
--== Author: sayhisam1		==--
--------------------------------
-- Implements publisher/subscriber logic that wraps around Roblox Remote Events (heavily based on postal.js)
-- USAGE:
-- 1) Create a networkChannel bound to the same remoteevent on both server and client
-- 2) Subscribe/publish to a specific topic in the channel

-- Explanation of topics:
-- Topics serve as a way to further break up the type of data being published into groups.
-- For example, I may define an 'Attack' channel, but a possible topic could be
-- 'Continue', which specifies a specific action related to attacks.
-- See: postal.js documentation for more info

-- GLOBALLY CACHE NETWORK CHANNELS BASED ON REMOTE EVENT --
local _cache = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Event = require(ReplicatedStorage.Objects.Shared.Event)

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local NetworkChannel = setmetatable({}, BaseObject)
NetworkChannel.__index = NetworkChannel
NetworkChannel.ClassName = script.Name

--Creates a new NetworkChannel
--@param string channel_name - A name for the channel
--@param RemoteEvent remote_event - A roblox remote_event to wrap around
--@param bool call_on_caller - specifies if the caller should also fire its own listening events when publishing
function NetworkChannel.new(channel_name, remote_event, call_on_caller)
    if _cache[remote_event] then
        assert(_cache[remote_event].Name == channel_name, "Tried to reuse RemoteEvent for differing network channels!")
        return _cache[remote_event]
    end
    assert(remote_event:IsA("RemoteEvent"), "Invalid remote event for network channel!")
    local self = setmetatable(BaseObject.new(channel_name), NetworkChannel)

    self._remoteEvent = remote_event
    self._topicCallbacks = {}
    self._topicCache = {} -- caches most recent value for topic (along with last received timestamp)
    self._callOnCaller = call_on_caller or false
    self.Name = channel_name

    if IsClient then
        self._maid:GiveTask(
            remote_event.OnClientEvent:Connect(
                function(topic, ...)
                    self:_callListeners(topic, ...)
                end
            )
        )
    else
        self._maid:GiveTask(
            remote_event.OnServerEvent:Connect(
                function(plr, topic, ...)
                    self:_callListeners(topic, plr, ...)
                end
            )
        )
    end

    self._maid:GiveTask(
        remote_event.AncestryChanged:connect(
            function()
                if not remote_event:IsDescendantOf(game) then
                    self:Destroy()
                end
            end
        )
    )
    _cache[remote_event] = self
    return self
end

--Publishes data to the remote event (for all players!)
--@param string topic - A 'topic' to publish data to
--@param variadic data - Data to send to publish under the topic
function NetworkChannel:Publish(topic, ...)
    assert(type(topic) == "string", "ERROR: Topic needs to be a string!")
    if IsClient then
        self._remoteEvent:FireServer(topic, ...)
    elseif IsServer then
        self._remoteEvent:FireAllClients(topic, ...)
    end
    if self._callOnCaller then
        self:_callListeners(topic, ...)
    end
end

--Publishes data to the remote event (for a specific player!)
--@param Player - A Player to publish to
--@param string topic - A 'topic' to publish data to
--@param variadic data - Data to send to publish under the topic
function NetworkChannel:PublishPlayer(plr, topic, ...)
    assert(type(topic) == "string", "ERROR: Topic needs to be a string!")
    assert(IsServer, "PublishPlayer can only be called from server!")
    assert(type(plr) == "userdata", "Attempted to publish to Invalid player " .. tostring(plr) .. " (type: " .. type(plr) .. ")")
    self:Log(1, "Publish player", self._remoteEvent:GetFullName(), plr, topic, ...)
    self._remoteEvent:FireClient(plr, topic, ...)
end

-- Unsubscribes from all topics
function NetworkChannel:UnsubscribeAll()
    for i, v in pairs(self._topicCallbacks) do
        self._topicCallbacks[i] = nil
    end
    self._topicCallbacks = {}
end

--Subscribes to a given topic in the channel
--@param string topic - A 'topic' to subscribe to
--@param function callback - a callback function invoked when data is received for the topic (note - on server, this only applies to published info from the specified player)
--@param cache_lookup_time - If specified and a cached value exists for the given topic, and it happened within cache_lookup_time time, then it will immediately invoke the callback. This is used to prevent missed events when a party subscribes *just* after the other publishes.
--@return Disconnector - An object that allows for an :Unsubscribe (or :Disconnect - both are equivalent) call to unsubscribe from the topic
function NetworkChannel:Subscribe(topic, callback, cache_lookup_time)
    assert(type(topic) == "string", "Topic needs to be a string!")
    assert(type(callback) == "function", "Callback must be a function!")
    self:Log(1, "Subscribed", topic)
    if not self._topicCallbacks[topic] then
        self._topicCallbacks[topic] = Event.new()
        self._maid:GiveTask(
            function()
                warn("CLEARING TOPIC", topic)
                self._topicCallbacks[topic]:Destroy()
                self._topicCallbacks[topic] = nil
            end
        )
    end

    if cache_lookup_time then
        local cached = self._topicCache[topic]
        if cached and (tick() - cached.Timestamp) <= cache_lookup_time then
            callback(unpack(cached.Values))
        end
    end

    local event = self._topicCallbacks[topic]
    return event:Connect(callback)
end

-- Waits for the topic to receive, and then returns the received value
function NetworkChannel:Wait(topic, timeout)
    timeout = timeout or 5 -- default timeout is 5 seconds
    local data = nil
    local start_time = tick()
    local listener =
        self:Subscribe(
        topic,
        function(...)
            data = {...}
        end
    )
    while (not data) and (tick() - start_time < timeout) do
        wait(.1) -- spinlock for data
    end
    listener:Destroy()
    return unpack(data)
end

--Cleanup the network channel and all bound events when done
function NetworkChannel:Destroy()
    self:Log(1, "Destroyed!")
    _cache[self._remoteEvent] = nil
    self._maid:Destroy()
end

-- Calls all the listeners for a given topic, passing params
function NetworkChannel:_callListeners(topic, ...)
    self:Log(1, "Receive broadcast on topic", topic, ..., "(handler:", self._topicCallbacks[topic], ")")
    self._topicCache[topic] = {
        Values = {...},
        Timestamp = tick()
    }
    if not self._topicCallbacks[topic] then
        return
    end
    self._topicCallbacks[topic]:Fire(...)
end

return NetworkChannel
