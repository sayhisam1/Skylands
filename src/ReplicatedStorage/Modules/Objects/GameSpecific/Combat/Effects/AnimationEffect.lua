local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Effect = require("YieldingEffect")
local Maid = require("Maid")
local AnimationEffect = setmetatable({}, Effect)
AnimationEffect.__index = AnimationEffect

function AnimationEffect:New(owner, animation)
    self.__index = self
    local humanoid = owner:GetHumanoid()
    while not humanoid do
        wait()
    end
    local track = humanoid:LoadAnimation(animation)
    while (track.Length == 0) do
        warn("WAITING FOR ", track, animation, track.Length)
        track:Destroy()
        track = humanoid:LoadAnimation(animation)
        wait()
    end
    local obj = setmetatable(Effect:New(track.Length), self)
    obj._animation = animation
    obj._owner = owner
    obj._loadedTrack = track
    
    obj._keyframeBinds = {}
    obj._maid = Maid.new()
    return obj
end

-- Bind an effect to occur at a specific keyframe in the animation
function AnimationEffect:BindKeyframeEffect(effect, keyframe, stop_keyframe)
    assert(type(keyframe) == "string", "Keyframe must be a string name!")
    local keyframe_event = self._loadedTrack:GetMarkerReachedSignal(keyframe)
    self._maid:GiveTask(
        keyframe_event:Connect(
            function()
                effect:Start()
            end
        )
    )
    if stop_keyframe then
        local stop_keyframe_event = self._loadedTrack:GetMarkerReachedSignal(stop_keyframe)
        self._maid:GiveTask(
            stop_keyframe_event:Connect(
                function()
                    effect:Stop()
                end
            )
        )
    end
    self._maid:GiveTask(effect)
    self._keyframeBinds[#self._keyframeBinds + 1] = {
        Keyframe = keyframe,
        Effect = effect,
        Time = self._loadedTrack:GetTimeOfKeyframe(keyframe),
        StopTime = (stop_keyframe and self._loadedTrack:GetTimeOfKeyframe(stop_keyframe)) or math.huge
    }
end

-- Start the animation effect (i.e. start playing the effect)
function AnimationEffect:Start()
    self._running = true
    if IsClient or self._owner.IsBot then
        self._loadedTrack:Play()
        self._loadedTrack.Stopped:Connect(
            function()
                self._running = false
                self:Yield()
            end
        )
    elseif IsServer then
        -- we don't actually run the animation here - this should be left to server to avoid weird glitchy effects
        for _, effect_data in pairs(self._keyframeBinds) do
            coroutine.wrap(
                function()
                    wait(effect_data.Time)
                    if self._running then
                        effect_data.Effect:Start()
                    end
                end
            )()
            coroutine.wrap(
                function()
                    if effect_data.StopTime ~= math.huge then
                        wait(effect_data.StopTime)
                        if self._running then
                            effect_data.Effect:Stop()
                        end
                    end
                end
            )()
        end
    end
end

-- Start the animation and all bound keyframe effects
function AnimationEffect:Stop()
    self._running = false
    self._loadedTrack:Stop()
    for _, effect_data in pairs(self._keyframeBinds) do
        local effect = effect_data.Effect
        coroutine.wrap(
            function()
                effect:Stop()
            end
        )()
    end
end

function AnimationEffect:GetTotalTime()
    return self._loadedTrack.Length
end

function AnimationEffect:Destroy()
    self:Stop()
    self._maid:Destroy()
    self._animation = nil
    self._keyframeBinds = nil
    --self._loadedTrack:Destroy()
end
return AnimationEffect
