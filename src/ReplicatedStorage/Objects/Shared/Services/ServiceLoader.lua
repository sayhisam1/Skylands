-------------------------------
--// SERVICE LOADER OBJECT \\--
-------------------------------
-- Responsible for handling service loading/unloading, and allows for dependencies to be rectified automatically
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local Queue = require(ReplicatedStorage.Objects.Shared.Queue)
local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)

local REMOTE_DIR_NAME = "_serverRemotes"

if IsServer then
    local dir = Instance.new("Folder")
    dir.Name = REMOTE_DIR_NAME
    dir.Parent = ReplicatedStorage
end

local REMOTE_DIR = ReplicatedStorage:WaitForChild(REMOTE_DIR_NAME)

local ServiceLoader = setmetatable({}, BaseObject)
ServiceLoader.__index = ServiceLoader
ServiceLoader.ClassName = script.Name

-- Recursively search for service with name (doesn't go to submodules)
local function recursiveSearch(start_dir, name)
    local dirs = Queue.new()
    dirs:Enqueue(start_dir)
    while not dirs:IsEmpty() do
        local dir = dirs:Dequeue()
        for _, v in ipairs(dir:GetChildren()) do
            if (v.Name == name) then
                return v
            end
            if v:IsA("Folder") then
                dirs:Enqueue(v)
            end
        end
    end
end

local function getAllModules(start_dir)
    local dirs = Queue.new()
    dirs:Enqueue(start_dir)
    local srvs = {}
    while not dirs:IsEmpty() do
        local dir = dirs:Dequeue()
        for _, v in ipairs(dir:GetChildren()) do
            if (v:IsA("ModuleScript")) then
                srvs[#srvs + 1] = v
            end
            if v:IsA("Folder") then
                dirs:Enqueue(v)
            end
        end
    end
    return srvs
end

local function getAllServices(start_dir)
    local dirs = Queue.new()
    dirs:Enqueue(start_dir)
    local srvs = {}
    while not dirs:IsEmpty() do
        local dir = dirs:Dequeue()
        for _, v in ipairs(dir:GetChildren()) do
            if (v:IsA("ModuleScript")) then
                srvs[#srvs + 1] = v
            end
            if v:IsA("Folder") then
                dirs:Enqueue(v)
            end
        end
    end
    return srvs
end

-- Creates a new service loader
-- @param directory		A roblox instance whose children will be loaded as services
-- @return ServiceLoader	Returns a new service loader object
function ServiceLoader.new(directory)
    local self = setmetatable(BaseObject.new(), ServiceLoader)
    self.Directory = directory
    self.ServiceTable = {}

    -- check for duplicate services of same name
    local seen = {}
    for i, v in pairs(getAllModules(directory)) do
        if seen[v.Name] then
            error("DUPLICATE MODULE " .. v.Name)
        else
            seen[v.Name] = true
        end
    end
    -- Lazy Loading of Services Here (incase it is referenced before prefetch is finished) --
    setmetatable(
        self.ServiceTable,
        {
            __index = function(t, i)
                if rawget(t, i) ~= nil then
                    return rawget(t, i)
                end
                local srv = recursiveSearch(directory, i)
                if (srv) then
                    rawset(t, i, require(srv))
                    return rawget(t, i)
                end
            end,
            __newindex = function(t, i, v)
                assert(type(v) == "table", "Attempted to add service " .. i .. " of invalid type " .. type(v))
                rawset(t, i, v)
            end
        }
    )

    return self
end

function ServiceLoader:PrefetchServices()
    self:Log(1, "PREFETCHING SERVICES...")
    for i, v in pairs(getAllServices(self.Directory)) do
        self:Log(1, "\tPrefetching", v:GetFullName(), "...")

        self:Log(1, "\t", v.Name)
        if not rawget(self.ServiceTable, v.Name) then
            rawset(self.ServiceTable, v.Name, require(v))
            assert(
                type(self.ServiceTable[v.Name]) == "table",
                "Invalid service " .. v.Name .. " of type " .. type(self.ServiceTable[v.Name])
            )
        end
    end
end

function ServiceLoader:LoadService(name, level, seen)
    level = level or 1
    seen = seen or {}
    assert(self.ServiceTable[name], "Invalid service " .. name .. "!")
    if (seen[name]) then
        return
    end
    seen[name] = true
    local service = self.ServiceTable[name]
    if not service.Enabled then
        self:Log(1, "Skipped disabled service", name)
        return
    end
    assert(
        type(service) == "table",
        "Invalid service " .. name .. " of type " .. type(service) .. " (must be a ServiceObject!)"
    )
    if service._loaded then
        return
    end
    self:Log(2, string.rep("\t", level, ""), name)
    for j, k in pairs(service.Dependencies) do
        assert(self.ServiceTable[k], "Invalid service dependency " .. k .. " (from service " .. name .. ")!")
        self:LoadService(k, level + 1, seen)
    end
    if (type(service._load) == "function") then
        -- dependency injection --
        service.Services = self.ServiceTable
        service:_load()
    end
end

function ServiceLoader:UnloadService(name, level)
    level = level or 1
    self:Log(1, string.rep("\t", level, ""), name)
    assert(self.ServiceTable[name], "Invalid service " .. name .. "!")
    local service = self.ServiceTable[name]
    assert(type(service) == "table", "Invalid service type " .. type(service) .. " (must be a ServiceObject!)")
    for j, k in pairs(service.Dependencies) do
        self:UnloadService(k, level + 1)
    end
    if (type(service._unload) == "function") then
        service:_unload()
    end
end

function ServiceLoader:LoadAllServices()
    self:Log(2, "LOADING SERVICES")
    for i, v in pairs(self.ServiceTable) do
        self:LoadService(i)
    end
    self:Log(2, "SERVICES LOADED!")
end

function ServiceLoader:UnloadAllServices()
    self:Log(2, "UNLOADING SERVICES")
    for i, v in pairs(self.ServiceTable) do
        self:UnloadService(i)
    end
    self:Log(2, "SERVICES UNLOADED!")
end

return ServiceLoader
