------------------------
--// SERVICE OBJECT \\--
------------------------
-- Responsible for representing a service - a singleton object which implements Service:Load and Service:Unload
local DEBUGMODE = false
local printd = function()
end
if DEBUGMODE then
    printd = function(...)
        if DEBUGMODE then
            print(...)
        end
    end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Channel = require("Channel")
local NetworkChannel = require("NetworkChannel")
local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()
local REMOTE_DIR_NAME = "_serviceRemotes"
if IsServer then
    local dir = Instance.new("Folder")
    dir.Name = REMOTE_DIR_NAME
    dir.Parent = ReplicatedStorage
end
local REMOTE_DIR = game:GetService("ReplicatedStorage"):WaitForChild(REMOTE_DIR_NAME)
local Service = {}

function Service:New(name)
    self.__index = self
    self.Enabled = true
    self._className = "Service"
    -- Enforce service loaded before function calls work
    self.__newindex = function(t, key, value)
        if (key ~= nil and type(value) == "function" and key ~= "Load" and key ~= "Unload" and not self[key]) then
            rawset(
                t,
                key,
                function(...)
                    while not t._loaded --[[print("WAITING FOR",key,t._loaded,t.Name)]] do
                        wait()
                    end -- make sure the service loads before allowing the function to fire
                    return value(...)
                end
            )
        else
            rawset(t, key, value)
        end
    end
    local newobj = setmetatable({}, self)
    assert(type(name) == "string", "ERROR: invalid parameter 'name' with type " .. type(name) .. " (must be 'string')!")
    printd("CREATING NEW SERVICE", name)
    newobj.Name = name
    newobj.Dependencies = {}
    newobj._channel = Channel:New(name) -- Instantiate a Channel to allow for event driven communication between services, without polluting the global Signal namespace
    newobj._loaded = false

    return newobj
end

function Service:AddDependencies(dependencies)
    if (type(dependencies) == "table") then
        for i, v in pairs(dependencies) do
            assert(type(v) == "string", "ERROR: Dependencies must be a string name corresponding to the dependency!")
            self.Dependencies[#self.Dependencies + 1] = v
        end
    elseif (type(dependencies) == "string") then
        self.Dependencies[#self.Dependencies + 1] = dependencies
    end
end

function Service:GetChannel()
    return self._channel
end
function Service:GetNetworkChannel()
    if not self._networkchannel then
        if IsServer then
            local event = Instance.new("RemoteEvent")
            event.Name = self.Name
            event.Parent = REMOTE_DIR
            self._remoteEvent = event
        elseif IsClient then
            self._remoteEvent = REMOTE_DIR:WaitForChild(self.Name)
        end
        self._networkchannel = NetworkChannel:New(self.Name, self._remoteEvent)
    end

    return self._networkchannel
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
    printd("INTERNAL LOAD CALLED FOR", self.Name)
    if self._loaded then
        return
    end
    self._loaded = true -- need to make sure we can call our own functions from within itself
    self:Load(...)
    printd("INTERNAL LOAD FINISH")
end

function Service:_unload(...)
    if not self._loaded then
        return
    end
    self._loaded = false
    self:Unload(...)
    self._channel:UnsubscribeAll()
    self._networkchannel:UnsubscribeAll()
end

return Service
