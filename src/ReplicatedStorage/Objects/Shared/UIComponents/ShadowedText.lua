local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)

local ShadowedText = Roact.Component:extend("ShadowedText")

function ShadowedText:render()
    return Roact.createFragment(
        {
            MainText = Roact.createElement(
                "TextLabel",
                {
                    BackgroundTransparency = 1,
                    TextStrokeColor3 = self.props.TextStrokeColor3,
                    TextStrokeTransparency = self.props.TextStrokeTransparency,
                    TextColor3 = self.props.TextColor3,
                    TextScaled = self.props.TextScaled or true,
                    Font = self.props.Font,
                    Position = self.props.Position,
                    Size = self.props.Size,
                    TextSize = self.props.TextSize or 12,
                    Text = self.props.Text,
                    AnchorPoint = self.props.AnchorPoint or Vector2.new(0, 0),
                    ZIndex = (self.props.ZIndex and self.props.ZIndex + 1) or 2,
                    Rotation = self.props.Rotation or 0,
                }
            ),
            ShadowText = Roact.createElement(
                "TextLabel",
                {
                    BackgroundTransparency = 1,
                    TextStrokeColor3 = self.props.ShadowTextStrokeColor3,
                    TextStrokeTransparency = self.props.ShadowTextStrokeTransparency,
                    TextColor3 = self.props.ShadowTextColor3,
                    TextScaled = self.props.TextScaled or true,
                    Font = self.props.Font,
                    Position = self.props.Position + self.props.ShadowOffset,
                    Size = self.props.Size,
                    TextSize = self.props.TextSize or 12,
                    Text = self.props.Text,
                    AnchorPoint = self.props.AnchorPoint or Vector2.new(0, 0),
                    ZIndex = self.props.ZIndex or 1,
                    Rotation = self.props.Rotation or 0,
                }
            )
        }
    )
end

return ShadowedText
