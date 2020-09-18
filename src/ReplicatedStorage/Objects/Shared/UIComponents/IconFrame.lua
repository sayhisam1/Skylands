local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)

local IconFrame = Roact.Component:extend("IconFrame")

function IconFrame:render()
    local zindex = self.props.ZIndex or 50
    return Roact.createElement(
        "Frame",
        {
            BackgroundTransparency = self.props.BackgroundTransparency or 1,
            BackgroundColor3 = self.props.BackgroundColor3,
            Size = self.props.Size,
            Position = self.props.Position,
            Rotation = self.props.Rotation,
            LayoutOrder = self.props.LayoutOrder,
            AnchorPoint = self.props.AnchorPoint or Vector2.new(0, 0),
            ZIndex = zindex
        },
        {
            UIListLayout = Roact.createElement(
                "UIListLayout",
                {
                    FillDirection = Enum.FillDirection.Horizontal,
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    HorizontalAlignment = Enum.HorizontalAlignment.Left,
                    VerticalAlignment = Enum.VerticalAlignment.Center
                }
            ),
            ContentFrame = Roact.createElement(
                "Frame",
                {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(.8, 0, 1, 0),
                    LayoutOrder = 2,
                    ZIndex = zindex + 1
                },
                self.props[Roact.Children]
            ),
            Icon = Roact.createElement(
                "ImageLabel",
                {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.new(0, 0, .5, 0),
                    Size = UDim2.new(1, 0, 1 * (self.props.ImageScale or 1), 0),
                    Image = self.props.Image,
                    ZIndex = zindex + 1,
                    LayoutOrder = 1,
                },
                {
                    UIAspectRatioConstraint = Roact.createElement(
                        "UIAspectRatioConstraint",
                        {
                            AspectRatio = 1,
                            DominantAxis = Enum.DominantAxis.Width
                        }
                    )
                }
            )
        }
    )
end

return IconFrame
