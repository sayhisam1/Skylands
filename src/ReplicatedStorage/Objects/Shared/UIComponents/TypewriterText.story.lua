local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local TypewriterText = require(ReplicatedStorage.Objects.Shared.UIComponents.TypewriterText)

return function(target)
    local gui =
        Roact.createElement(
        "Frame",
        {
            Size = UDim2.new(.4, 0, .3, 0),
            Position = UDim2.new(.5, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            ZIndex = 1,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        },
        {
            Roact.createElement(
                TypewriterText,
                {
                    Text = "* You are filled with determination. (x2 mining speed)",
                    Size = UDim2.new(.95, 0, .95, 0),
                    Position = UDim2.new(.5, 0, .5, 0),
                    AnchorPoint = Vector2.new(.5, .5),
                    FontSize = Enum.FontSize.Size32,
                    TextWrapped = true,
                    Font = Enum.Font.Arcade,
                    -- TextScaled = true,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    ZIndex = 2
                }
            )
        }
    )
    local handle = Roact.mount(gui, target)
    return function()
        Roact.unmount(handle)
    end
end
