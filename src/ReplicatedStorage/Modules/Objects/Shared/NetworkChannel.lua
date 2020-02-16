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


local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local datadump = require("DataDump")

local Maid = require("Maid")
local fastSpawn = require("fastSpawn")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()
local Players = game:GetService("Players")
local DEBUGMODE = RunService:IsStudio()
local NetworkChannel = {}

--Creates a new NetworkChannel
--@param string channel_name - A name for the channel
--@param RemoteEvent remote_event - A roblox remote_event to wrap around
--@param bool call_on_caller - specifies if the caller should also fire its own listening events when publishing
function NetworkChannel:New(channel_name, remote_event, call_on_caller)
    assert(
        type(channel_name) == "string",
        "Invalid channel name! (Received argument of type " .. type(channel_name) .. ", expected string"
    )
    assert(type(remote_event) == "userdata" and remote_event:IsA("RemoteEvent"), "Invalid remote event passed!")

    self.__index = self
    local newobj = setmetatable({}, self)
    newobj.Name = channel_name
    newobj._remoteEvent = remote_event
    newobj._topicCallbacks = {}
    newobj._topicCache = {} -- caches most recent value for topic (along with last received timestamp)
    newobj._maid = Maid.new()
    newobj._callOnCaller = call_on_caller or false
    if IsClient then
        newobj._maid:GiveTask(
            remote_event.OnClientEvent:Connect(
                function(topic, ...)
                    newobj:_callListeners(topic, ...)
                end
            )
        )
    else
        newobj._maid:GiveTask(
            remote_event.OnServerEvent:Connect(
                function(plr, topic, ...)
                    newobj:_callListeners(topic, plr, ...)
                end
            )
        )
    end

    return newobj
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
    if (type(plr) == "table" and type(plr.GetReference) == "function") then
        plr = plr:GetReference()
    end
    assert(
        type(plr) == "userdata",
        "Attempted to publish to Invalid player " .. tostring(plr) .. " (type: " .. type(plr) .. ")"
    )
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
--@param max_time_differential - If specified and a cached value exists for the given topic, and it happened within max_time_differential time, then it will immediately invoke the callback. This is used to prevent missed events when a party subscribes *just* after the other publishes.
--@return Disconnector - An object that allows for an :Unsubscribe (or :Disconnect - both are equivalent) call to unsubscribe from the topic
function NetworkChannel:Subscribe(topic, callback, max_time_differential)
    assert(type(topic) == "string", "Topic needs to be a string!")
    assert(type(callback) == "function", "Callback must be a function!")
    if not self._topicCallbacks[topic] then
        self._topicCallbacks[topic] = {}
    end
    local arr = self._topicCallbacks[topic]
    arr[callback] = callback

    if max_time_differential then
        local cached = self._topicCache[topic]
        if cached and (tick() - cached.Timestamp) <= max_time_differential then
            callback(unpack(cached.Values))
        end
    end

    local disconnector = {}
    function disconnector:Disconnect()
        arr[callback] = nil
    end
    disconnector.Destroy = disconnector.Disconnect
    disconnector.Unsubscribe = disconnector.Disconnect

    return disconnector
end

--Cleanup the network channel and all bound events when done
function NetworkChannel:Destroy()
    self.Connection:Disconnect()
    self.Connection = nil
    for i, v in pairs(self._topicCallbacks) do
        self._topicCallbacks[i] = nil
    end
    self._topicCallbacks = {}
    for i, v in pairs(self) do
        self[i] = nil
    end
end

-- Calls all the listeners for a given topic, passing params
function NetworkChannel:_callListeners(topic, ...)
    self._topicCache[topic] = {
        Values = {...},
        Timestamp = tick()
    }
    if not self._topicCallbacks[topic] then
        return
    end
    for _, listener in pairs(self._topicCallbacks[topic]) do
        if DEBUGMODE then
            fastSpawn(listener, ...)
        else
            coroutine.wrap(listener)(...)
        end
    end
end

-- On server side, we can specify what player we want to listen to (filtering all other receives)
function NetworkChannel:SetPlayer(player)
    self.Player = player
end

return NetworkChannel
