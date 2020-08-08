local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local GuiService = game:GetService("GuiService")
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

return function()
    return Roact.createElement(
        "Frame",
        {
            Position = UDim2.new(.5, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = true
        },
        {
            BlackAccent = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.4, 0, 2, 0),
                    Position = UDim2.new(0.61, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Rotation = 10,
                    ZIndex = 2,
                    BorderSizePixel = 0
                }
            ),
            WhiteAccent = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.42, 0, 2, 0),
                    Position = UDim2.new(0.6, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = 10,
                    ZIndex = 1,
                    BorderSizePixel = 0
                }
            ),
            WhiteStripe = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.8, 0, .3, 0),
                    Position = UDim2.new(0.35, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = 60,
                    ZIndex = 3,
                    BorderSizePixel = 0
                }
            ),
            ShopkeepText = Roact.createElement(ShadowedText, {
                ShadowOffset = UDim2.new(.005, 0, .005, 0),
                Size = UDim2.new(.3, 0, .3, 0),
                Position = UDim2.new(0.65, 0, 0.1, 0),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                TextStrokeColor3 = Color3.fromRGB(0, 0, 0),
                ShadowTextStrokeColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                Text="The Pickaxe Emporium",
                ZIndex=1000
            })
        }
    )
end
