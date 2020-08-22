local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)

return function()
    return Roact.createFragment(
        {
            Stripes = Roact.createElement(
                "ImageLabel",
                {
                    AnchorPoint = Vector2.new(.5, .5),
                    BackgroundTransparency = 1,
                    Position = UDim2.new(.5, 0, .5, 0),
                    Size = UDim2.new(1, 0, 1, 0),
                    ImageTransparency = 0.1,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 64, 0, 64),
                    Image = "rbxassetid://4651117489",
                    ImageColor3 = Color3.fromRGB(202, 0, 0)
                }
            )
        }
    )
end
