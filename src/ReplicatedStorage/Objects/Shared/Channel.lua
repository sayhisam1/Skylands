--------------------------------
--// CHANNEL OBJECT \\--
--== Author: sayhisam1		==--
--------------------------------
-- Implements publisher/subscriber logic
-- 1) Create a Channel
-- 2) Subscribe/publish to a specific topic in the channel

-- Explanation of topics:
-- Topics serve as a way to further break up the type of data being published into groups.
-- For example, I may define an 'Attack' channel, but a possible topic could be
-- 'Continue', which specifies a specific action related to attacks.
-- See: postal.js documentation for more info

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local fastSpawn = require(ReplicatedStorage.Utils.fastSpawn)

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local Channel = setmetatable({}, BaseObject)
Channel.__index = Channel
Channel.ClassName = script.Name

--Creates a new Channel
--@param string (optional) channel_name - A name for the channel
function Channel.new(channel_name)
    local self = setmetatable(BaseObject.new(channel_name), Channel)
    self._topicCallbacks = {}
    self._wrappedEventConnections = {}
    return self
end

--Publishes data to the remote event
--@param string topic - A 'topic' to publish data to
--@param variadic data - Data to send to publish under the topic
function Channel:Publish(topic, ...)
    assert(type(topic) == "string", "ERROR: Topic needs to be a string!")
    local bound = self._topicCallbacks[topic]
    if bound then
        for i, v in pairs(bound) do
            fastSpawn(v, ...)
        end
    end
end

--Subscribes to a given topic in the channel
--@param string topic - A 'topic' to subscribe to
--@param function callback - a callback function invoked when data is received for the topic
--@return Disconnector - An object that allows for an :Unsubscribe (or :Disconnect - both are equivalent) call to unsubscribe from the topic
function Channel:Subscribe(topic, callback)
    assert(type(topic) == "string", "Topic needs to be a string!")
    assert(type(callback) == "function", "Callback needs to be a function!")
    if not self._topicCallbacks[topic] then
        self._topicCallbacks[topic] = {}
    end
    local arr = self._topicCallbacks[topic]
    arr[callback] = callback
    local disconnector = {}
    function disconnector:Disconnect()
        arr[callback] = nil
    end
    function disconnector:Unsubscribe()
        arr[callback] = nil
    end
    function disconnector:Destroy()
        arr[callback] = nil
    end
    return disconnector
end

--Wraps the channel to publish to a given topic whenever a given rbxevent fires
--@param RBXScriptSignal event -- The event to wrap around
--@param string topic -- the topic to broadcast on
--@return -- The disconnector for the event
function Channel:WrapEvent(event, topic)
    local disc =
        event.Fired:Connect(
        function(...)
            self:Publish(topic, ...)
        end
    )
    self._wrappedEventConnections[#self._wrappedEventConnections + 1] = disc
    return disc
end

-- Disconnects from all wrapped events
function Channel:ClearWrappedEvents()
    for i, v in pairs(self._wrappedEventConnections) do
        v:Disconnect()
        self[i] = nil
    end
    self._wrappedEventConnections = {}
end

--Cleanup the Channel when done
function Channel:Destroy()
    self:UnsubscribeAll()
    self:ClearWrappedEvents()
end

--Remove all bound topics/functions
function Channel:UnsubscribeAll()
    for i, v in pairs(self._topicCallbacks) do
        self._topicCallbacks[i] = nil
    end
    self._topicCallbacks = {}
end

return Channel
