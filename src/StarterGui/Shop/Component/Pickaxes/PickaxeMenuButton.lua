local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

local PickaxeMenuButton = Roact.PureComponent:extend("PickaxeMenuButton")

function PickaxeMenuButton:render()
    self.props.IconProps.BackgroundTransparency = self.props.IconProps.BackgroundTransparency or 1
    self.props.IconProps.Size = self.props.IconProps.Size or UDim2.new(.8, 0, .8, 0)
    self.props.IconProps.Position = self.props.IconProps.Position or UDim2.new(.5, 0, .5, 0)
    self.props.IconProps.AnchorPoint = self.props.IconProps.AnchorPoint or self.props.AnchorPoint or Vector2.new(.5, .5)

    if self.props.BackgroundIconProps then
        self.props.BackgroundIconProps.BackgroundTransparency =
            self.props.BackgroundIconProps.BackgroundTransparency or 1
        self.props.BackgroundIconProps.Size = self.props.BackgroundIconProps.Size or UDim2.new(.8, 0, .8, 0)
        self.props.BackgroundIconProps.Position = self.props.BackgroundIconProps.Position or UDim2.new(.5, 0, .5, 0)
        self.props.BackgroundIconProps.AnchorPoint =
            self.props.BackgroundIconProps.AnchorPoint or self.props.AnchorPoint or Vector2.new(.5, .5)
    end

    self.props.TextProps.ShadowOffset = self.props.TextProps.ShadowOffset or UDim2.new(.02, 0, .01, 0)
    self.props.TextProps.Size = self.props.TextProps.Size or UDim2.new(1, 0, .3, 0)
    self.props.TextProps.Position = self.props.TextProps.Position or UDim2.new(.5, 0, 1, 0)
    self.props.TextProps.AnchorPoint = self.props.TextProps.AnchorPoint or self.props.AnchorPoint or Vector2.new(.5, 1)
    self.props.TextProps.TextColor3 = self.props.TextProps.TextColor3 or Color3.fromRGB(255, 255, 255)
    self.props.TextProps.ShadowTextColor3 = self.props.TextProps.ShadowTextColor3 or Color3.fromRGB(0, 0, 0)
    self.props.TextProps.TextStrokeColor3 = self.props.TextProps.TextStrokeColor3 or Color3.fromRGB(0, 0, 0)
    self.props.TextProps.ShadowTextStrokeColor3 =
        self.props.TextProps.ShadowTextStrokeColor3 or Color3.fromRGB(255, 255, 255)

    return Roact.createElement(
        "TextButton",
        {
            BackgroundTransparency = 1,
            Size = self.props.Size,
            Position = self.props.Position,
            LayoutOrder = self.props.LayoutOrder,
            Text = "",
            ZIndex = 1000,
            AnchorPoint = self.props.AnchorPoint or Vector2.new(.5, .5),
            [Roact.Event.MouseButton1Click] = self.props[Roact.Event.MouseButton1Click],
            [Roact.Event.MouseEnter] = self.props[Roact.Event.MouseEnter],
            [Roact.Event.MouseLeave] = self.props[Roact.Event.MouseLeave]
        },
        {
            Label = Roact.createElement(ShadowedText, self.props.TextProps),
            Icon = Roact.createElement("ImageLabel", self.props.IconProps),
            BackgroundIcon = self.props.BackgroundIconProps and
                Roact.createElement("ImageLabel", self.props.BackgroundIconProps),
            UIAspectRatioConstraint = self.props.AspectRatio and
                Roact.createElement(
                    "UIAspectRatioConstraint",
                    {
                        AspectType = self.props.AspectType or Enum.AspectType.ScaleWithParentSize,
                        DominantAxis = self.props.DominantAxis or Enum.DominantAxis.Height,
                        AspectRatio = self.props.AspectRatio or 1
                    }
                )
        }
    )
end

return PickaxeMenuButton
