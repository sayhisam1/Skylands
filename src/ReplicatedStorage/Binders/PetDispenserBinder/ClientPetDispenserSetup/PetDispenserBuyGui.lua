local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)
local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

local gui = Roact.Component:extend("PetDispenser")
gui.defaultProps = {
    [AnimatedContainer.Damping] = .7,
    [AnimatedContainer.Frequency] = 2,
    [AnimatedContainer.Targets] = {
        Size = UDim2.new(.24, 0, 0, 0)
    }
}

function gui.getDerivedStateFromProps(nextProps, lastState)
    return {
        [AnimatedContainer.Damping] = lastState[AnimatedContainer.Damping] or nextProps[AnimatedContainer.Damping],
        [AnimatedContainer.Frequency] = lastState[AnimatedContainer.Frequency] or nextProps[AnimatedContainer.Frequency],
        [AnimatedContainer.Targets] = lastState[AnimatedContainer.Targets] or nextProps[AnimatedContainer.Targets]
    }
end

function gui:render()
    local choices = self.props.Choices
    for i, curr in pairs(choices) do
        local k = curr.Pet
        local v = curr.Rarity
        if not k then
            continue
        end
        local petName = k:GetAttribute("DisplayName")
        local component = Roact.createElement(k:GetPetViewportElement(), {
            BackgroundColor3 = Color3.fromRGB(143, 203, 255),
            LayoutOrder = i,
            UIAspect = Roact.createElement("UIAspectRatioConstraint")
        },
            {
                PetName = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = petName,
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, .2, 0),
                        Position = UDim2.new(.5, 0, 0, 0),
                        AnchorPoint = Vector2.new(.5, 0),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 1
                    }
                ),
                Rarity = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = string.format("%3.1f%%", v),
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, .2, 0),
                        Position = UDim2.new(.5, 0, 1, 0),
                        AnchorPoint = Vector2.new(.5, 1),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 1
                    }
                ),
            }
        )
        choices[i] = component
    end
    choices = Roact.createFragment(choices)

    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping],
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency],
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets],
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(.5, 0, .4, 0),
            BackgroundTransparency = 1,
            ZIndex = 10000
        },
        {
            CloseButton = Roact.createElement(
                "ImageButton",
                {
                    Size = UDim2.new(.1, 0, .1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    ZIndex = 10011,
                    Image = "http://www.roblox.com/asset/?id=5617680082",
                    BackgroundTransparency = 1,
                    Modal = true,
                    [Roact.Event.MouseButton1Down] = function()
                        self:setState(
                            {
                                [AnimatedContainer.Targets] = {
                                    Size = UDim2.new(0, 0, 0, 0)
                                },
                                [AnimatedContainer.Damping] = 1,
                                [AnimatedContainer.Frequency] = 4
                            }
                        )
                        wait(.6)
                        self.props.CloseCallback()
                    end
                },
                {
                    UIAspectRatio = Roact.createElement("UIAspectRatioConstraint")
                }
            ),
            GemCost = Roact.createElement(
                "Frame",
                {
                    Size = UDim2.new(.5, 0, .3, 0),
                    Position = UDim2.new(-.5, -5, .1, 0),
                    BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                    ClipsDescendants = true,
                    ZIndex = 3,
                },
                {
                    IconFrame = Roact.createElement(IconFrame,
                    {
                        Size = UDim2.new(.7, 0, .7, 0),
                        Position = UDim2.new(.5, 0 ,.5 ,0),
                        AnchorPoint = Vector2.new(.5, .5),
                        Image = "rbxassetid://5629921147",
                        BackgroundTransparency = 1,
                        BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                        ZIndex = 4,
                    },
                    {
                        ShadowText = Roact.createElement(
                            ShadowedText,
                            {
                                Font = Enum.Font.GothamBold,
                                Text = string.format("%s", NumberToStr(self.props.GemCost)),
                                TextScaled = true,
                                BackgroundTransparency = 1,
                                TextColor3 = Color3.fromRGB(248, 110, 110),
                                TextStrokeColor3 = Color3.fromRGB(248, 110, 110),
                                TextStrokeTransparency = 0,
                                Size = UDim2.new(1, 0, 1, 0),
                                Position = UDim2.new(0, 0, 0, 0),
                                ShadowTextColor3 = Color3.fromRGB(190, 11, 11),
                                ShadowOffset = UDim2.new(0.02, 0, 0.02, 0),
                                ZIndex = 10
                            }
                        )
                    }),
                    UICorner = Roact.createElement("UICorner", {
                        CornerRadius = UDim.new(.1, 0),
                    })
                }
            ),
            Tray = Roact.createElement(
                "Frame",
                {
                    Size = UDim2.new(1, 0, .4, 0),
                    Position = UDim2.new(0, 0, 1, 5),
                    BackgroundTransparency = 1
                },
                {
                    UIListLayout = Roact.createElement(
                        "UIListLayout",
                        {
                            FillDirection = Enum.FillDirection.Horizontal,
                            Padding = UDim.new(0, 10),
                            HorizontalAlignment = Enum.HorizontalAlignment.Center
                        }
                    ),
                    Auto = Roact.createElement(
                        "ImageButton",
                        {
                            BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                            Size = UDim2.new(1, 0, 1, 0),
                            [Roact.Event.MouseButton1Down] = self.props.AutoCallback,
                            Modal = true,
                        },
                        {
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(0, 5)
                                }
                            ),
                            UIAspectRatio = Roact.createElement("UIAspectRatioConstraint"),
                            Letter = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .8, 0),
                                    TextScaled = true,
                                    Text = "T",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            ),
                            Label = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .2, 0),
                                    Position = UDim2.new(0, 0, .97, 0),
                                    AnchorPoint = Vector2.new(0, 1),
                                    TextScaled = true,
                                    Text = "AUTO",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            )
                        }
                    ),
                    B = Roact.createElement(
                        "ImageButton",
                        {
                            BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                            Size = UDim2.new(1, 0, 1, 0),
                            [Roact.Event.MouseButton1Down] = self.props.OpenThreeCallback,
                            Modal = true,
                        },
                        {
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(0, 5)
                                }
                            ),
                            UIAspectRatio = Roact.createElement("UIAspectRatioConstraint"),
                            Letter = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .8, 0),
                                    TextScaled = true,
                                    Text = "R",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            ),
                            Label = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .2, 0),
                                    Position = UDim2.new(0, 0, .97, 0),
                                    AnchorPoint = Vector2.new(0, 1),
                                    TextScaled = true,
                                    Text = "OPEN 3",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            )
                        }
                    ),
                    C = Roact.createElement(
                        "ImageButton",
                        {
                            BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                            Size = UDim2.new(1, 0, 1, 0),
                            [Roact.Event.MouseButton1Down] = self.props.OpenOneCallback,
                            Modal = true,
                        },
                        {
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(0, 5)
                                }
                            ),
                            UIAspectRatio = Roact.createElement("UIAspectRatioConstraint"),
                            Letter = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .8, 0),
                                    TextScaled = true,
                                    Text = "E",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            ),
                            Label = Roact.createElement(
                                "TextLabel",
                                {
                                    Size = UDim2.new(1, 0, .2, 0),
                                    Position = UDim2.new(0, 0, .97, 0),
                                    AnchorPoint = Vector2.new(0, 1),
                                    TextScaled = true,
                                    Text = "Open 1",
                                    ZIndex = 1002,
                                    BackgroundTransparency = 1,
                                    TextColor3 = Color3.fromRGB(255, 255, 255),
                                    Font = Enum.Font.GothamBlack
                                }
                            )
                        }
                    )
                }
            ),
            Pets = Roact.createElement(
                "ImageLabel",
                {
                    Size = UDim2.new(1, 0, 1, 0),
                    Position = UDim2.new(.5, 0, .5, 0),
                    AnchorPoint = Vector2.new(.5, .5),
                    BackgroundTransparency = 1,
                    ZIndex = 10002,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 64, 0, 64),
                    Image = "rbxassetid://4651117489",
                    ImageColor3 = Color3.fromRGB(135, 198, 254),
                    ClipsDescendants = true
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    ),
                    UIGrid = Roact.createElement(
                        "UIGridLayout",
                        {
                            CellSize = UDim2.new(.3, 0, .3, 0),
                            CellPadding = UDim2.new(0, 10, 0, 10),
                            SortOrder = Enum.SortOrder.LayoutOrder
                        }
                    ),
                    choices
                }
            ),
            UIAspectRatioConstraint = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectRatio = 1.433,
                    DominantAxis = Enum.DominantAxis.Width,
                    AspectType = Enum.AspectType.ScaleWithParentSize
                }
            )
        }
    )
end

return gui
