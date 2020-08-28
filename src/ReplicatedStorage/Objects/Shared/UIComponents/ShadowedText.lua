local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)

local ShadowedText = Roact.Component:extend("ShadowedText")

ShadowedText.defaultProps = {
    BackgroundTransparency = 1,
    TextScaled = true,
    TextSize = 12,
    ZIndex = 1,
}
function ShadowedText:render()
    return Roact.createFragment(
        {
            MainText = Roact.createElement(
                "TextLabel",
                {
                    BackgroundTransparency = self.props.BackgroundTransparency,
                    TextStrokeColor3 = self.props.TextStrokeColor3,
                    TextStrokeTransparency = self.props.TextStrokeTransparency,
                    TextColor3 = self.props.TextColor3,
                    TextScaled = self.props.TextScaled,
                    Font = self.props.Font,
                    Position = self.props.Position,
                    Size = self.props.Size,
                    TextSize = self.props.TextSize,
                    Text = self.props.Text,
                    AnchorPoint = self.props.AnchorPoint,
                    ZIndex = self.props.ZIndex + 1,
                    Rotation = self.props.Rotation
                }
            ),
            ShadowText = Roact.createElement(
                "TextLabel",
                {
                    BackgroundTransparency = 1,
                    TextStrokeColor3 = self.props.ShadowTextStrokeColor3,
                    TextStrokeTransparency = self.props.ShadowTextStrokeTransparency,
                    TextColor3 = self.props.ShadowTextColor3,
                    TextScaled = self.props.TextScaled,
                    Font = self.props.Font,
                    Position = self.props.Position + self.props.ShadowOffset,
                    Size = self.props.Size,
                    TextSize = self.props.TextSize,
                    Text = self.props.Text,
                    AnchorPoint = self.props.AnchorPoint,
                    ZIndex = self.props.ZIndex,
                    Rotation = self.props.Rotation
                }
            )
        }
    )
end

return ShadowedText
