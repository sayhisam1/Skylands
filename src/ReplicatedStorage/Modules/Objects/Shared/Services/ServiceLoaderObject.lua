-------------------------------
--// SERVICE LOADER OBJECT \\--
-------------------------------
-- Responsible for handling service loading/unloading, and allows for dependencies to be rectified automatically
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local Queue = require("Queue")
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

local ServiceLoader = {}

-- Recursively search for service with name (doesn't go to submodules)
local function recursiveSearch(start_dir, name)
    local dirs = Queue:New()
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
    local dirs = Queue:New()
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
    local dirs = Queue:New()
    dirs:Enqueue(start_dir)
    local srvs = {}
    while not dirs:IsEmpty() do
        local dir = dirs:Dequeue()
        for _, v in ipairs(dir:GetChildren()) do
            if (v:IsA("ModuleScript") and require(v)._className == "Service") then
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
function ServiceLoader:New(directory)
    self.__index = self
    local newobj = setmetatable({}, self)
    newobj.Directory = directory
    newobj.ServiceTable = {}

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
        newobj.ServiceTable,
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

    return newobj
end

function ServiceLoader:PrefetchServices()
    printd("PREFETCHING SERVICES...")
    for i, v in pairs(getAllServices(self.Directory)) do
        printd("\t", v.Name)
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
        return
    end
    assert(
        type(service) == "table",
        "Invalid service " .. name .. " of type " .. type(service) .. " (must be a ServiceObject!)"
    )
    if service._loaded then
        return
    end
    printd(string.rep("\t", level, ""), name)
    for j, k in pairs(service.Dependencies) do
        assert(self.ServiceTable[k], "Invalid service dependency " .. k .. " (from service " .. name .. ")!")
        self:LoadService(k, level + 1, seen)
    end
    if (type(service._load) == "function") then
        service:_load()
    end
end

function ServiceLoader:UnloadService(name, level)
    level = level or 1
    printd(string.rep("\t", level, ""), name)
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
    printd("LOADING SERVICES")
    for i, v in pairs(self.ServiceTable) do
        self:LoadService(i)
    end
    printd("SERVICES LOADED!")
end

function ServiceLoader:UnloadAllServices()
    printd("UNLOADING SERVICES")
    for i, v in pairs(self.ServiceTable) do
        self:UnloadService(i)
    end
    printd("SERVICES UNLOADED!")
end

return ServiceLoader
