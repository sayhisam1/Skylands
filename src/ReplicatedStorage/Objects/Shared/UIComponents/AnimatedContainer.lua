local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local spr = require(ReplicatedStorage.Lib.spr)
local Roact = require(ReplicatedStorage.Lib.Roact)
local Component = Roact.Component

local AnimatedContainer = Component:extend("AnimatedContainer")

AnimatedContainer.Targets = "ANIMATED_TARGETS"
AnimatedContainer.Damping = "ANIMATED_DAMPING"
AnimatedContainer.Frequency = "ANIMATED_FREQUENCY"
AnimatedContainer.ContainerType = "ANIMATED_CONTAINER_TYPE"

function AnimatedContainer:_animate()
    local instance = self.ref:getValue()
    local targets = self.state[AnimatedContainer.Targets]
    local damping = self.state[AnimatedContainer.Damping] or 1
    local frequency = self.state[AnimatedContainer.Frequency] or 1
    if instance and targets then
        spr.target(instance, damping, frequency, targets)
    end
end

function AnimatedContainer.getDerivedStateFromProps(props, state)
    return {
        [AnimatedContainer.Targets] = props[AnimatedContainer.Targets],
        [AnimatedContainer.Damping] = props[AnimatedContainer.Damping],
        [AnimatedContainer.Frequency] = props[AnimatedContainer.Frequency]
    }
end

function AnimatedContainer:init()
    self.ref = Roact.createRef()
end

function AnimatedContainer:didMount()
    self:_animate()
end

function AnimatedContainer:didUpdate()
    self:_animate()
end

function AnimatedContainer:willUnmount()
    local instance = self.ref:getValue()
    if instance then
        spr.stop(instance)
    end
end

function AnimatedContainer:render()
    local newProps = TableUtil.shallow(self.props)
    newProps =
        TableUtil.filter(
        newProps,
        function(k)
            return k ~= AnimatedContainer.Targets and k ~= AnimatedContainer.Damping and k ~= AnimatedContainer.Frequency and
                k ~= AnimatedContainer.ContainerType
        end
    )
    newProps[Roact.Ref] = self.ref
    return Roact.createElement(self.props[AnimatedContainer.ContainerType] or "Frame", newProps)
end

return AnimatedContainer
