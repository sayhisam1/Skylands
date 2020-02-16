local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Maid = require("Maid")

local Effect = {}
Effect.__index = Effect

function Effect:New(owner, parent)
    self.__index = self
    local obj = setmetatable({}, self)
    obj._func = function()
    end
    obj._parent = parent
    obj._maid = Maid.new()
    obj._owner = owner
    return obj
end

-- Start/Stop methods should be overloaded by inherited classes!
function Effect:Start(...)
    self._running = true
    coroutine.wrap(self._func)(self, ...)
end

function Effect:Stop()
    self._running = false
    self._maid:Destroy()
end

function Effect:Destroy()
    self:Stop()
end

function Effect:SetFunction(func)
    assert(type(func) == "function", "Tried to set invalid function!")
    self._func = func
end

function Effect:PlaySound(sound, options)
    if not self._running then
        return
    end

    if IsClient then
        _G.Services.SoundService:PlaySound(sound, options)
    else
        for _, plr in pairs(_G.Services.PlayerManager:GetNonBotPlayers()) do
            if plr ~= self._owner then
                _G.Services.EffectsService:ReplicateSound(plr, sound, options)
            end
        end
    end
end

function Effect:DealDamage(target, amount)
    if not self._running then
        return
    end
    if IsServer then self._owner:Attack(target, amount) end
end

function Effect:SetObjectProperty(object, property, value, revert_on_stop)
    assert(type(object) == 'userdata',"Invalid object provided with type "..type(object))
    if revert_on_stop then
        local old = object[property]
        local object = object
        self._maid:GiveTask(function()
            object[property] = old
        end)
    end
    object[property] = value
end

function Effect:EnableTrail(trail)
    self:SetObjectProperty(trail, "Enabled", true, true)
end

local Fling = require("Fling")
function Effect:KnockbackPlayer(plr, direction, magnitude)
    if IsClient then return end
    local rootpart = plr:GetCharacter().PrimaryPart
    local direction = direction.Unit
    Fling(rootpart, direction*magnitude)
end

function Effect:FreezePlayer(plr)
    local task = function()
        plr:Unfreeze()
    end
    self._maid:GiveTask(task)
    plr:Freeze()
end

function Effect:AddCleanupTask(task)
    self._maid:GiveTask(task)
end

function Effect:EmitParticleAtPosition(particle_name, position)
    if IsClient then
        _G.Services.EffectsService:EmitParticleAtPosition(particle_name, position)
    elseif IsServer then
        for _, plr in pairs(_G.Services.PlayerManager:GetNonBotPlayers()) do
            if plr ~= self._owner then
                _G.Services.EffectsService:ReplicateEmitParticleAtPosition(plr, particle_name, position)
            end
        end
    end

end

function Effect:GetOwner()
    return self._owner
end

return Effect
