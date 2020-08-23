local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)
local Instance = script.Parent

return function(data)
    return Roact.createElement(ViewportContainer, {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(.5, 0, .5, 0),
        AnchorPoint = Vector2.new(.5, .5),
        RenderedModel = Instance,
        CameraCFrame = CFrame.new(0, 0, 4) * CFrame.Angles(math.pi/4, math.pi/4, math.pi/4),
        ZIndex = 22
    })
end