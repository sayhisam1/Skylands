local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local YieldingEffect = require(ReplicatedStorage.Objects.Combat.Abstract.YieldingEffect)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local KeyframeWrapper = require(script.KeyframeWrapper)
local AnimationEffect = setmetatable({}, YieldingEffect)
AnimationEffect.__index = AnimationEffect
AnimationEffect.ClassName = script.Name

function AnimationEffect.new(animation, humanoid, fadetime, weight, speed)
    assert(animation, "No animation provided!")
    assert(humanoid, "No humanoid provided!")
    local track = humanoid:LoadAnimation(animation)
    while (track.Length == 0) do
        warn("WAITING FOR ", track, animation, track.Length)
        track:Destroy()
        track = humanoid:LoadAnimation(animation)
        wait()
    end
    local self = setmetatable(YieldingEffect.new(), AnimationEffect)
    self._animation = animation
    self._humanoid = humanoid
    self._loadedTrack = track
    self._keyframeBinds = {}

    self._maid:GiveTask(function()
        self._loadedTrack:Stop()
        self._loadedTrack:Destroy()
    end)

    self._fadetime = fadetime
    self._weight = weight
    self._speed = speed or 1
    return self
end

-- Bind an effect to occur at a specific keyframe in the animation
function AnimationEffect:BindKeyframeEffect(effect, start_keyframe, stop_keyframe)
    self:Log(1, "Binding keyframe effect",keyframe_name)
    local wrapper = KeyframeWrapper.new(self._loadedTrack, start_keyframe, function()
        effect:Start()
    end, stop_keyframe, function()
        effect:Stop()
    end, self._fadetime, self._weight, self._speed)
    self._maid:GiveTask(effect)
    self._maid:GiveTask(wrapper)
    self._keyframeBinds[#self._keyframeBinds + 1] = wrapper
end

-- Start the animation effect (i.e. start playing the effect)
function AnimationEffect:Start()
    self._running = true
    if IsClient then
        self._loadedTrack:Play(self._fadetime, self._weight, self._speed)
        self._loadedTrack.Stopped:Connect(
            function()
                self._running = false
                self:Yield()
            end
        )
    end
    for _, wrapper in pairs(self._keyframeBinds) do
        wrapper:Start()
    end
end

function AnimationEffect:GetTotalTime()
    return self._loadedTrack.Length / self._speed
end

return AnimationEffect
