local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)

return function()
    return Roact.createFragment(
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
                    ImageColor3 = Color3.fromRGB(135, 198, 254),
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    )
                }
            )
        }
    )
end
