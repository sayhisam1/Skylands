local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)

local PetIndicatorButton = Roact.Component:extend("PetIndicatorButton")

function PetIndicatorButton:render()
    return Roact.createElement(
        "Frame",
        {
            AnchorPoint = self.props.AnchorPoint,
            Size = self.props.Size,
            Position = self.props.Position,
            BackgroundColor3 = self.props.BackgroundColor3,
            BorderSizePixel = 0,
            ZIndex = 50
        },
        {
            UICorner = Roact.createElement(
                "UICorner",
                {
                    CornerRadius = UDim.new(.2, 0)
                }
            ),
            Roact.createElement(
                IconFrame,
                {
                    Size = UDim2.new(.6, 0, .6, 0),
                    Position = UDim2.new(.05, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, .5),
                    Image = self.props.Image,
                    ZIndex = 51
                },
                {
                    Slots = Roact.createElement(
                        "TextLabel",
                        {
                            Font = Enum.Font.GothamBold,
                            Text = self.props.Text,
                            TextScaled = true,
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.new(1, 1, 1),
                            Size = UDim2.new(1, 0, 1, 0),
                            ZIndex = 52
                        }
                    )
                }
            ),
            Roact.createElement(
                "ImageButton",
                {
                    ZIndex = 52,
                    Size = UDim2.new(.2, 0, .6, 0),
                    Position = UDim2.new(.75, 0, 0.5, 0),
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                    BorderSizePixel = 0,
                    Image = "rbxassetid://5585468882",
                    [Roact.Event.MouseEnter] = function(ref)
                        ref:TweenSize(UDim2.new(.22, 0, .62, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                    end,
                    [Roact.Event.MouseLeave] = function(ref)
                        ref:TweenSize(UDim2.new(.2, 0, .6, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                    end,
                    [Roact.Event.MouseButton1Click] = function(ref)
                        self.props.onClick(ref)
                    end
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.2, 0)
                        }
                    ),
                    UIAspectRatio = Roact.createElement("UIAspectRatioConstraint")
                }
            )
        }
    )
end

PetIndicatorButton =
    RoactRodux.connect(
    function(state, props)
        return {
            Text = props.TextGetter(state)
        }
    end
)(PetIndicatorButton)

return PetIndicatorButton
