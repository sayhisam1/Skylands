local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local SoundUtil = require(ReplicatedStorage.Utils.SoundUtil)
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local Effect = setmetatable({}, BaseObject)
Effect.__index = Effect
Effect.ClassName = script.Name

function Effect.new(func)
    local self = setmetatable(BaseObject.new(), Effect)
    self._func = func or function()
    end
    return self
end

-- Start/Stop methods should be overloaded by inherited classes!
function Effect:Start(...)
    self._running = true
    coroutine.wrap(
        function(...)
            local status, result = pcall(self._func, self, ...)
            self:Stop()
            if not status then
                error(result)
            end
        end
    )(...)
end

function Effect:Stop()
    if not self._running then
        return
    end
    self._running = false
    self._maid:Destroy()
end

function Effect:Destroy()
    self:Stop()
end

function Effect:SetFunction(func)
    assert(type(func) == "function", string.format("Tried to set invalid function of type %s!", tostring(type(func))))
    self._func = func
end

function Effect:PlaySound(sound, options)
    self:Log(1, "Playing sound", sound, "with options", options)
    if not self._running then
        self:Log(1, "Effect not running - aborted!")
        return
    end
    SoundUtil.PlaySound(sound, options)
end

function Effect:DealDamage(attacking_humanoid, target_humanoid, amount, location)
    if not self._running then
        return false
    end
    if IsServer then
        return Services.Combat:DealDamage(attacking_humanoid, target_humanoid, amount)
    end
    return false
end

function Effect:SetObjectProperty(object, property, value, revert_on_stop)
    assert(type(object) == "userdata", "Invalid object provided with type " .. type(object))
    if revert_on_stop then
        local old = object[property]
        local object = object
        self._maid:GiveTask(
            function()
                object[property] = old
            end
        )
    end
    object[property] = value
end

function Effect:AddCleanupTask(task)
    self._maid:GiveTask(task)
end

local ParticleUtil = require(ReplicatedStorage.Utils.ParticleUtil)
function Effect:EmitParticleAtPosition(particle, position, options)
    ParticleUtil.EmitParticleAtPosition(particle, position, options)
end

return Effect
