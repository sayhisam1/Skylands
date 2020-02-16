--------------------------------
--// MANAGER SERVICE OBJECT \\--
--------------------------------
-- Implements a wrapper around service objects that handles management of all items of a specific class
-- Automatically handles object syncing via networkchannels
local DEBUGMODE = false

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()
local DataDump = require("DataDump")
local Service = require("ServiceObject")
local Maid = require("Maid")
local Pickler = require("Pickler")

local Manager = {}

function Manager:New(name, classname)
    self.__index = self
    -- Enforce service loaded before function calls work
    self.__newindex = function(t, key, value)
        if (key ~= nil and type(value) == "function" and key ~= "Load" and key ~= "Unload" and not self[key]) then
            rawset(
                t,
                key,
                function(...)
                    while not t._loaded --[[print("WAITING FOR ",key,debug.traceback()) ]] do
                        wait()
                    end -- make sure the service loads before allowing the function to fire
                    return value(...)
                end
            )
        else
            rawset(t, key, value)
        end
    end

    assert(type(classname) == "string", "Unknown classname!")
    local manager = setmetatable(Service:New(name), Manager)
    manager._objectTbl = {}
    manager._networkMaid = Maid.new()
    manager._classname = classname
    -- inject functions into manager corresponding to class name
    for i, v in pairs(self) do
        if (type(v) == "function" and string.match(i, "Object")) then
            local n = string.gsub(i, "Object", classname)
            manager[n] = v
        end
    end
    return manager
end

function Manager:PrintD(...)
    if DEBUGMODE or self._DEBUGMODE then
        print(string.format("[%sManager] ",self._classname),...)
    end
end

function Manager:GetObjectById(id)
    local obj = self._objectTbl[id]
    return obj
end

function Manager:AddObject(object)
    assert(type(object) == "table", "Object must be a table!")
    assert(type(object.GetId) == "function", "Object contains no id getter!")
    self:PrintD("Adding object " .. tostring(object) .. " to manager!")
    --print(self._classname,"Manager ADDED OBJECT",object,object.Name)
    local prev = self._objectTbl[object:GetId()]
    if prev ~= nil and prev ~= object then
        error(string.format("Object Id collision! (prev: %s, new: %s)", tostring(prev), tostring(object)))
    end
    self._objectTbl[object:GetId()] = object
    if IsServer then
        self:SyncObject(object)
    end
end

function Manager:RemoveObjectById(id)
    assert(type(id) == "string" or type(id) == "number", "Invalid Id!")
    self:PrintD("Removing object with id " .. tostring(id) .. " from manager!")
    if (self._objectTbl[id]) then
        if (type(self._objectTbl[id].Destroy) == "function") then
            self._objectTbl[id]:Destroy()
        end
        if IsServer then
            self:GetNetworkChannel():Publish("Removed", {Id = id})
        end
    end
    self._objectTbl[id] = nil
end

function Manager:RemoveObject(object)
    assert(type(object) == "table", "Object must be a table!")
    assert(type(object.GetId) == "function", "Object contains no id getter!")
    self:RemoveObjectById(object:GetId())
end

function Manager:RemoveAllObjects()
    for id, obj in pairs(self._objectTbl) do
        self:RemoveObjectById(id)
    end
end

function Manager:GetObjects()
    return self._objectTbl
end

function Manager:SyncObject(object, sync_target_plr, ...)
    if IsClient then
        error("SyncObject called from client!")
    end
    local plrs = (sync_target_plr and {sync_target_plr}) or game.Players:GetPlayers()
    local pickled = Pickler:Pickle(object,...)
    for _, plr in pairs(plrs) do
        self:PrintD("Send data", object, "to", plr, "(pickled:", DataDump:dd(pickled), ")") 
        self:GetNetworkChannel():PublishPlayer(plr, "Updated", pickled)
    end
    return pickled
end
function Manager:_loadNetworkChannels()
    local network_channel = self:GetNetworkChannel()
    if IsClient then
        -- Calls when client sided manager receives an 'Updated' request
        self._networkMaid:GiveTask(
            network_channel:Subscribe(
                "Updated",
                function(data)
                    local unpickled = Pickler:Unpickle(data)
                    assert(unpickled, "Received invalid update!")
                    local old_obj = self:GetObjectById(unpickled:GetId())
                    if old_obj then -- merge data if already exists
                        self:PrintD("Merging", DataDump:dd(unpickled), "\ninto\n", DataDump:dd(old_obj))
                        Pickler:Merge(old_obj, unpickled)
                    else -- create new instance if doesn't exist
                        self:PrintD("Creating new object with id", unpickled:GetId(), "from recieved data: ", DataDump:dd(data))
                        self:AddObject(unpickled)
                    end
                end
            )
        )

        -- Calls when client sided manager receives a 'Removed' request (removes the object)
        self._networkMaid:GiveTask(
            network_channel:Subscribe(
                "Removed",
                function(data)
                    local id = data.Id
                    assert(
                        type(id) == "number" or type(id) == "string",
                        string.format("Invalid id for data %s", DataDump:dd(data))
                    )
                    self:RemoveObjectById(id)
                end
            )
        )
        network_channel:Publish("RequestInfo")
    end
    if IsServer then
        self._networkMaid:GiveTask(
            network_channel:Subscribe(
                "RequestInfo",
                function(plr, ...)
                    self:PrintD(plr, "Request info")
                    for i, v in pairs(self:GetObjects()) do
                        self:PrintD("\t Sync", i, v)
                        self:SyncObject(v, plr)
                    end
                end
            )
        )

        self._networkMaid:GiveTask(
            network_channel:Subscribe(
                "GetObject",
                function(plr, id, ...)
                    self:SyncObject(self:GetObjectById(id), plr)
                end
            )
        )
    end
end

function Manager:_unloadNetworkChannels()
    self._networkMaid:Destroy()
end
function Manager:_load(...)
    if self._loaded then
        return
    end
    self:_loadNetworkChannels()
    Service._load(self, ...)
end

function Manager:_unload(...)
    if not self._loaded then
        return
    end
    self:_unloadNetworkChannels()
    Service._unload(self, ...)
end

setmetatable(Manager, Service)
return Manager
