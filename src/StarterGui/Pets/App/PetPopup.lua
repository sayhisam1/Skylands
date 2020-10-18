-- PET MENU --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local Background = require(script.Parent:WaitForChild("Background"))

local gui = Roact.Component:extend("Shop")

function gui:render()
    local children = TableUtil.shallow(self.props[Roact.Children])
    children["UIAspectRatio"] =
        Roact.createElement(
        "UIAspectRatioConstraint",
        {
            AspectRatio = 1.39
        }
    )
    children["Background"] = Roact.createElement(Background)
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .5,
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 3,
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or
                {
                    Position = UDim2.new(.5, 0, .5, 0),
                    Size = UDim2.new(.7, 0, .7, 0)
                },
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(.5, 0, .5, 0),
            BackgroundTransparency = 1,
            ZIndex = 100
        },
        children
    )
end

return gui
