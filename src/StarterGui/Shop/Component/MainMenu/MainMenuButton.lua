local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local MainMenuButton = Roact.Component:extend("MenuButton")

function MainMenuButton:render()
    self.props.IconProps.BackgroundTransparency = 1
    self.props.IconProps.Size = UDim2.new(.8, 0, .8, 0)
    self.props.IconProps.Position = UDim2.new(.5, 0, .5, 0)
    self.props.IconProps.AnchorPoint = Vector2.new(.5, .5)

    self.props.TextProps.ShadowOffset = UDim2.new(.02, 0, .01, 0)
    self.props.TextProps.Size = UDim2.new(1, 0, .3, 0)
    self.props.TextProps.Position = UDim2.new(.5, 0, 1, 0)
    self.props.TextProps.AnchorPoint = Vector2.new(.5, 1)
    self.props.TextProps.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.props.TextProps.ShadowTextColor3 = Color3.fromRGB(0, 0, 0)
    self.props.TextProps.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    self.props.TextProps.ShadowTextStrokeColor3 = Color3.fromRGB(255, 255, 255)

    local mouseEnter = function()
        self:setState(
            {
                [AnimatedContainer.Targets] = {
                    Size = self.props.Size + UDim2.new(.02, 0, .02, 0),
                }
            }
        )
    end
    local mouseLeave = function()
        self:setState(
            {
                [AnimatedContainer.Targets] = {
                    Size = self.props.Size,
                }
            }
        )
    end
    return Roact.createElement(
        AnimatedContainer,
        {
            BackgroundTransparency = 1,
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .2,
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 3,
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or
                {
                    Size = self.props.Size
                },
            [AnimatedContainer.ContainerType] = "TextButton",
            Text = "",
            Position = self.props.Position,
            Size = self.props.Size,
            AnchorPoint = Vector2.new(.5, .5),
            [Roact.Event.MouseEnter] = mouseEnter,
            [Roact.Event.MouseLeave] = mouseLeave,
            [Roact.Event.MouseButton1Click] = self.props[Roact.Event.MouseButton1Click]
        },
        {
            Label = Roact.createElement(ShadowedText, self.props.TextProps),
            Icon = Roact.createElement("ImageLabel", self.props.IconProps),
            UIAspectRatioConstraint = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectType = Enum.AspectType.ScaleWithParentSize,
                    DominantAxis = Enum.DominantAxis.Height
                }
            )
        }
    )
end

return MainMenuButton
