local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()
local Effect = require("Effect")
local Maid = require("Maid")

local ProjectileEffect = setmetatable({}, Effect)
ProjectileEffect.__index = ProjectileEffect
ProjectileEffect.Name = script.Name

-- Creates a new projectile effect
function ProjectileEffect:New(owner, projectile_path, max_duration)
    self.__index = self
    local obj = setmetatable(Effect:New(owner), self)
    obj.MaxDuration = max_duration

    obj.ProjectilePath = projectile_path
    obj.StepEffects = {}

    return obj
end

function ProjectileEffect:_StepEffects(cf)
    for _, effect in pairs(self.StepEffects) do
        coroutine.wrap(
            function()
                local res = effect:Start(self, cf)
            end
        )()
    end
end

local function local_perception_filter(time, delay, time_goal)
    local actual_time = time + delay
    -- if we have synced with the server's time already, we can revert to normal time
    if time >= time_goal then
        return actual_time
    end

    -- Otherwise, we have two cases:
    -- 1) we were the client that fired, so we need to slow the projectile down to allow others to catch up or
    -- 2) we are a receiving client, in which case we speed up the projectile to accomodate for lag
    -- in both cases, we just multiply to linearly scale time
    local ratio = (time_goal + delay) / time_goal
    return time * ratio
end

function ProjectileEffect:Start(...)
    local path = self.ProjectilePath
    if type(path.Create) == "function" then
        path = path:Create(self._owner, ...)
    end

    local max_duration = self.MaxDuration
    local start_cf = path:GetCFrameAtTime(0)
    self:_StepEffects(start_cf)
    local dt = 0
    local delay = 0
    if IsClient then
        delay = _G.Clock:GetDelay()
        if self._owner == _G.LocalPlayer then
            delay = delay * -1
        end
    end
    local event =
        RunService.Heartbeat:Connect(
        function(step)
            dt = dt + step
            if dt >= max_duration then
                self:StopStepping()
                return
            end
            local new_cf
            if IsClient then
                local dt_skewed = local_perception_filter(dt, delay, .5)
                new_cf = path:GetCFrameAtTime(dt_skewed)
            else
                new_cf = path:GetCFrameAtTime(dt)
            end
            self:_StepEffects(new_cf)
        end
    )
    self._maid:GiveTask(event)
end

-- Overrides base effect stop (Projectile effects aren't stoppable directly)
function ProjectileEffect:Stop()
end

function ProjectileEffect:SetStepFunction(func)
    self:SetFunction(func)
end
function ProjectileEffect:AddStepEffect(effect)
    self.StepEffects[#self.StepEffects + 1] = effect
end

function ProjectileEffect:StopStepping()
    self._maid:Destroy()
    for _, effect in pairs(self.StepEffects) do
        effect:Stop()
    end
end

return ProjectileEffect
