local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NumberToStr = require(ReplicatedStorage.Utils.NumberToStr)
local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)

local gui = Roact.Component:extend("PetDispenser")
gui.defaultProps = {
    [AnimatedContainer.Damping] = .7,
    [AnimatedContainer.Frequency] = 2,
    [AnimatedContainer.Targets] = {
        Size = UDim2.new(1, 0, .5, 0)
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
    local petChoices = require(self.props.Dispenser:FindFirstChild("PetProbabilities")):GetNormalizedProbabilities()
    local choices = {}
    for k, v in pairs(petChoices) do
        choices[#choices+1] = {
            Pet = k,
            Probability = v
        }
    end
    table.sort(choices, function(a,b)
        return a.Probability > b.Probability
    end)
    for i, curr in pairs(choices) do
        local k = curr.Pet
        local v = curr.Probability
        local petName = k:GetAttribute("DisplayName")
        local component = k:MakePetViewport(
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
                Probability = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = string.format("%3.1f%%", v * 100),
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
                UIAspectRatioConstraint = Roact.createElement("UIAspectRatioConstraint")
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
            Position = UDim2.new(.5, 0, .5, 0),
            BackgroundTransparency = 1,
            ZIndex = 10000
        },
        {
            Background = Roact.createElement(
                "ImageLabel",
                {
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.new(.5, 0, .5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                    BorderSizePixel = 0,
                    ZIndex = 9,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 64, 0, 64),
                    Image = "rbxassetid://4651117489",
                    ImageColor3 = Color3.fromRGB(135, 198, 254)
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    )
                }
            ),
            CloseButton = Roact.createElement(
                "ImageButton",
                {
                    Size = UDim2.new(.1, 0, .1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    ZIndex = 100,
                    Image = "http://www.roblox.com/asset/?id=5617680082",
                    BackgroundTransparency = 1,
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
                    end
                },
                {
                    UIAspectRatio = Roact.createElement("UIAspectRatioConstraint")
                }
            ),
            GemCost = Roact.createElement(
                IconFrame,
                {
                    Size = UDim2.new(.35, 0, .3, 0),
                    Position = UDim2.new(0.15, 0, .65, 0),
                    Image = "rbxassetid://5629921147"
                },
                {
                    ShadowText = Roact.createElement(
                        ShadowedText,
                        {
                            Font = Enum.Font.GothamBold,
                            Text = string.format("%s", NumberToStr(self.props.Dispenser:GetAttribute("GemCost"))),
                            TextScaled = true,
                            BackgroundTransparency = 1,
                            TextColor3 = Color3.fromRGB(248, 110, 110),
                            TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
                            TextStrokeTransparency = 0,
                            Size = UDim2.new(1, 0, 1, 0),
                            Position = UDim2.new(0, 0, 0, 0),
                            ShadowTextColor3 = Color3.fromRGB(255, 255, 255),
                            ShadowOffset = UDim2.new(0.02, 0, 0.02, 0),
                            ZIndex = 10
                        }
                    )
                }
            ),
            BuyButton = Roact.createElement(
                "TextButton",
                {
                    Font = Enum.Font.GothamBold,
                    Text = "Buy",
                    TextScaled = true,
                    BackgroundColor3 = Color3.fromRGB(53, 115, 248),
                    BorderSizePixel = 0,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 1,
                    Size = UDim2.new(.3, 0, .3, 0),
                    Position = UDim2.new(0.6, 0, .65, 0),
                    AnchorPoint = Vector2.new(0, 0),
                    ZIndex = 1001,
                    [Roact.Event.MouseButton1Down] = function()
                        local nc = self.props.Dispenser:GetNetworkChannel()
                        nc:Publish("TRY_BUY")
                    end
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.2, 0)
                        }
                    )
                }
            ),
            Frame = Roact.createElement(
                "ImageLabel",
                {
                    Size = UDim2.new(.8, 0, .5, 0),
                    Position = UDim2.new(.5, 0, .1, 0),
                    AnchorPoint = Vector2.new(.5, 0),
                    BackgroundTransparency = 1,
                    ZIndex = 10002,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 64, 0, 64),
                    Image = "rbxassetid://4651117489",
                    ImageColor3 = Color3.fromRGB(164, 213, 255)
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    ),
                    ScrollingFrame = Roact.createElement(
                        "ScrollingFrame",
                        {
                            Size = UDim2.new(1, 0, 1, 0),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            CanvasSize = UDim2.new(0, 0, 3, 0)
                        },
                        {
                            UIGrid = Roact.createElement(
                                "UIGridLayout",
                                {
                                    CellSize = UDim2.new(0, 100, 0, 100),
                                    CellPadding = UDim2.new(0, 10, 0, 10),
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }
                            ),
                            choices
                        }
                    )
                }
            ),
            UIAspectRatioConstraint = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectRatio = 1.618
                }
            )
        }
    )
end

return function(root, dispenser)
    local handle =
        Roact.mount(
        Roact.createElement(
            gui,
            {
                Dispenser = dispenser
            }
        ),
        root
    )
    return function()
        Roact.unmount(handle)
    end
end
