local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()

local KeyframeWrapper = setmetatable({}, BaseObject)
KeyframeWrapper.__index = KeyframeWrapper
KeyframeWrapper.ClassName = script.Name

function KeyframeWrapper.new(loaded_track, start_keyframe, start_callback, stop_keyframe, stop_callback, fadetime, weight, speed)
    assert(loaded_track:IsA("AnimationTrack"), "Invalid loaded track!")
    local self = setmetatable(BaseObject.new(), KeyframeWrapper)
    self._fadetime = fadetime
    self._weight = weight
    self._speed = speed or 1

    self._loadedTrack = loaded_track
    self._loadedTrack.Stopped:Connect(
        function()
            self._running = false
        end
    )
    self:_connectKeyframeCallback(start_keyframe, start_callback)
    self._startTime = self._loadedTrack:GetTimeOfKeyframe(start_keyframe) / self._speed
    self._startCallback = start_callback
    if stop_keyframe then
        self:_connectKeyframeCallback(stop_keyframe, stop_callback)
        self._stopTime = self._loadedTrack:GetTimeOfKeyframe(stop_callback) / self._speed
        self._stopCallback = stop_callback
    end

    return self
end

function KeyframeWrapper:_connectKeyframeCallback(keyframe, callback)
    local keyframe_event = self._loadedTrack:GetMarkerReachedSignal(keyframe)
    self._maid:GiveTask(keyframe_event:Connect(callback))
end

function KeyframeWrapper:GetStartTime()
    return self._startTime
end

function KeyframeWrapper:GetStopTime()
    return self._stopTime
end

function KeyframeWrapper:GetAnimationTime()
    return self._loadedTrack.Length / self._speed
end

function KeyframeWrapper:Start()
    self._running = true
    if IsServer then
        coroutine.wrap(
            function()
                wait(self:GetAnimationTime())
                self._running = false
            end
        )()
        coroutine.wrap(
            function()
                wait(self:GetStartTime())
                if not self._running then
                    return
                end
                self._startCallback()
            end
        )()
        if self._stopTime then
            coroutine.wrap(
                function()
                    wait(self:GetStopTime())
                    if not self._running then
                        return
                    end
                    self._stopCallback()
                end
            )()
        end
    end
end

return KeyframeWrapper
