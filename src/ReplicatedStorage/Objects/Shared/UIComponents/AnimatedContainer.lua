local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedComponent = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedComponent)

local Container = AnimatedComponent:extend("Container")

function Container:init()
    self.ref = Roact.createRef()
end

function Container:didMount()
    local instance = self.ref:getValue()
    instance.Position = self.props["InitialPosition"]
    self:_animateOnMount()
end

function Container:render()
    return Roact.createElement(
        "Frame",
        {
            ClipsDescendants = self.props.ClipsDescendants,
            AnchorPoint = self.props.AnchorPoint or Vector2.new(.5, .5),
            BackgroundTransparency = 1,
            Position = self.props.Position or UDim2.new(.5, 0, .5, 0),
            Size = self.props.Size or UDim2.new(1, 0, 1, 0),
            -- roact specific --
            [Roact.Ref] = self.ref,
            [Roact.Children] = self.props[Roact.Children]
        }
    )
end
return Container
