local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local GuiService = game:GetService("GuiService")

return function()
    return Roact.createElement(
        "Frame",
        {
            Position = UDim2.new(.5, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            ClipsDescendants = false
        },
        {
            BlackAccent = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(.5, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.4, 0, 2, 0),
                    Position = UDim2.new(1.15, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Rotation = -10,
                    ZIndex = 2,
                    BorderSizePixel = 0
                }
            ),
            WhiteAccent = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0.5, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.42, 0, 2, 0),
                    Position = UDim2.new(1.15, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = -10,
                    ZIndex = 1,
                    BorderSizePixel = 0
                }
            ),
            WhiteStripe1 = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.1, 0, 3, 0),
                    Position = UDim2.new(1.3, 0, 0.5, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = 60,
                    ZIndex = 3,
                    BorderSizePixel = 0
                }
            ),
            WhiteStripe2 = Roact.createElement(
                "Frame",
                {
                    AnchorPoint = Vector2.new(0, .5),
                    BackgroundTransparency = 0,
                    Size = UDim2.new(0.05, 0, 3, 0),
                    Position = UDim2.new(1, 0, 0.1, 0),
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Rotation = -60,
                    ZIndex = 3,
                    BorderSizePixel = 0
                }
            )
        }
    )
end
