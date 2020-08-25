------------------------
--// SERVICE OBJECT \\--
------------------------
-- Responsible for representing a service - a singleton object which implements Service:Load and Service:Unload
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local HttpService = game:GetService("HttpService")

-- Setup remote directories
local REMOTE_DIR_NAME = "_serverRemotes"
local REMOTE_DIR = ReplicatedStorage:WaitForChild(REMOTE_DIR_NAME)

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local Channel = require(ReplicatedStorage.Objects.Shared.Channel)
local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)

local Service =
    setmetatable(
    {
        Enabled = true
    },
    BaseObject
)

Service.ClassName = script.Name
Service.__index = Service
Service.__newindex = function(t, key, value)
    if key ~= nil and type(value) == "function" and key ~= "Load" and key ~= "Unload" and not Service[key] then
        rawset(
            t,
            key,
            function(...)
                while not t._loaded do
                    wait()
                end -- make sure the service loads before allowing the function to fire
                return value(...)
            end
        )
    else
        rawset(t, key, value)
    end
end

function Service.new(name)
    -- Enforce service loaded before function calls work
    local self = setmetatable(BaseObject.new(name), Service)
    assert(type(name) == "string", "ERROR: invalid parameter 'name' with type " .. type(name) .. " (must be 'string')!")
    self:Log(1, "CREATING NEW SERVICE", name)
    self.Name = name
    self.Dependencies = {}
    self._channel = Channel.new(name) -- Instantiate a Channel to allow for event driven communication between services
    self._loaded = false

    if IsServer then
        local event = REMOTE_DIR:FindFirstChild(self.Name) or Instance.new("RemoteEvent")
        event.Name = self.Name
        event.Parent = REMOTE_DIR
        self._networkchannel = NetworkChannel.new(self.Name, event)
    end
    if IsClient then
        self._serverChannels = {}
    end
    return self
end

function Service:AddDependencies(dependencies)
    if type(dependencies) == "table" then
        for i, v in pairs(dependencies) do
            assert(type(v) == "string", "ERROR: Dependencies must be a string name corresponding to the dependency!")
            self.Dependencies[#self.Dependencies + 1] = v
        end
    elseif type(dependencies) == "string" then
        self.Dependencies[#self.Dependencies + 1] = dependencies
    end
end

function Service:GetChannel()
    return self._channel
end

function Service:GetNetworkChannel()
    assert(IsServer, "Can only get network channel from server!")
    return self._networkchannel
end

-- Republishes all received data from a network channel under a given topic to the service's channel
function Service:ForwardNetworkTopicToChannel(network_channel, topic)
    self._maid:GiveTask(
        network_channel:Subscribe(
            topic,
            function(...)
                self:GetChannel():Publish(topic, ...)
            end
        )
    )
end

function Service:GetServerNetworkChannel(server_service_name)
    assert(type(server_service_name) == "string", "Invalid server service name!")
    assert(IsClient, "Can only get server network channels on the client!")
    if self._serverChannels[server_service_name] then
        return self._serverChannels[server_service_name]
    end
    local event = REMOTE_DIR:WaitForChild(server_service_name)
    local channel = NetworkChannel.new(server_service_name, event)
    self._serverChannels[server_service_name] = channel
    return channel
end

function Service:GetLoadId()
    return self._loadId
end

function Service:HookPlayerAction(func)
    for _, plr in pairs(Players:GetPlayers()) do
        func(plr)
    end
    self._maid:GiveTask(Players.PlayerAdded:Connect(func))
    self._maid:GiveTask(Players.PlayerRemoving:Connect(function(plr)
        self._maid[plr]:Destroy()
    end))
end
------------------------------
--// OVERLOADED FUNCTIONS \\--
------------------------------
function Service:Load()
end
function Service:Unload()
end

---------------------------
--// PRIVATE FUNCTIONS \\--
---------------------------
function Service:_load(...)
    self:Log(1, "INTERNAL LOAD CALLED FOR", self.Name)
    if self._loaded then
        return
    end
    self._loaded = true -- need to make sure we can call our own functions from within itself
    self._loadId = HttpService:GenerateGUID(false)
    self:Load(...)
    self:Log(1, "INTERNAL LOAD FINISH")
end

function Service:_unload(...)
    if not self._loaded then
        return
    end
    self._loaded = false
    self._loadId = nil
    self:Unload(...)
    self._channel:UnsubscribeAll()
    self._networkchannel:UnsubscribeAll()
end

return Service
