------------------------
--// SERVICE OBJECT \\--
------------------------
-- Responsible for representing a service - a singleton object which implements Service:Load and Service:Unload
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local HttpService = game:GetService("HttpService")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

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
    self._loaded = false

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

function Service:GetLoadId()
    return self._loadId
end

function Service:HookPlayerAction(func)
    for _, plr in pairs(Players:GetPlayers()) do
        coroutine.wrap(func)(plr)
    end
    self._maid:GiveTask(Players.PlayerAdded:Connect(func))
    self._maid:GiveTask(
        Players.PlayerRemoving:Connect(
            function(plr)
                self._maid[plr] = nil
            end
        )
    )
end
------------------------------
--// OVERLOADED FUNCTIONS \\--
------------------------------
function Service:Load()
    self:Log(1, "Load function not overlaoded!")
end
function Service:Unload()
    self:Log(1, "Unload function not overlaoded!")
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
