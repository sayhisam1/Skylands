local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

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

    return Roact.createElement(
        "TextButton",
        {
            BackgroundTransparency = 1,
            Size = self.props.Size,
            Position = self.props.Position,
            Text = "",
            AnchorPoint = self.props.AnchorPoint or Vector2.new(.5, .5),
            [Roact.Event.MouseButton1Click] = self.props[Roact.Event.MouseButton1Click],
            [Roact.Event.MouseEnter] = self.props[Roact.Event.MouseEnter],
            [Roact.Event.MouseLeave] = self.props[Roact.Event.MouseLeave]
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