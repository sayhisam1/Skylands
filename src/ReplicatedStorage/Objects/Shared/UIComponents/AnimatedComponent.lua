local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Component = Roact.Component

local AnimatedComponent = Component:extend("AnimatedComponent")
AnimatedComponent.extend = Component.extend

AnimatedComponent.TweenTargetsOnMount = "TWEEN_TARGETS_MOUNT"
AnimatedComponent.TweenInfoOnMount = "TWEENINFO_MOUNT"
AnimatedComponent.TweenInfoOnUnmount = "TWEENINFO_UNMOUNT"
AnimatedComponent.TweenTargetsOnUnmount = "TWEEN_TARGETS_UNMOUNT"

function AnimatedComponent:_animateOnMount()
    local tween_info = self.props[AnimatedComponent.TweenInfoOnMount]
    local tween_targets = self.props[AnimatedComponent.TweenTargetsOnMount]
    local instance = self.ref:getValue()
    if tween_info and tween_targets and instance then
        local tween = TweenService:Create(instance, tween_info, tween_targets)
        tween:Play()
    end
end

function AnimatedComponent:_animateOnUnmount()
    local tween_info = self.props[AnimatedComponent.TweenInfoOnUnmount]
    local tween_targets = self.props[AnimatedComponent.TweenTargetsOnUnmount]
    local instance = self.ref:getValue()
    if tween_info and tween_targets and instance then
        local tween = TweenService:Create(instance, tween_info, tween_targets)

        tween:Play()
        tween.Completed:Wait()
    end
end

function AnimatedComponent:didMount()
    self:_animateOnMount()
end

function AnimatedComponent:willUnmount()
    self:_animateOnUnmount()
end

return AnimatedComponent
