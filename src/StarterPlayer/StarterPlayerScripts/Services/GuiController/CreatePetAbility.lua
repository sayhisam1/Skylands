local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local GuiController = Services.GuiController
local Roact = require(ReplicatedStorage.Lib.Roact)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)

local PetAbility = Roact.Component:extend("PetAbility")

function PetAbility:init()
    self.transparency,
        self.updateTransparency = Roact.createBinding(0)
end

function PetAbility:render()
    local model = self.props.PetModel
    local vp =
        Roact.createElement(
        ViewportContainer,
        {
            RenderedModel = model,
            CameraCFrame = CFrame.new(0, 0, 3)
        },
        {
            UICorner = Roact.createElement(
                "UICorner",
                {
                    CornerRadius = UDim.new(1, 0)
                }
            )
        }
    )
    return Roact.createElement(
        "TextButton",
        {
            BackgroundTransparency = self.props.BackgroundTransparency,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            [Roact.Event.MouseButton1Down] = self.props.Callback,
            Text = "",
            BorderSizePixel = 5,
            ClipsDescendants = true
        },
        {
            Viewport = vp,
            UICorner = Roact.createElement(
                "UICorner",
                {
                    CornerRadius = UDim.new(1, 0)
                }
            )
        }
    )
end

return function(model, callback)
    local abilities = GuiController:GetPetAbilitiesGui()
    local element =
        Roact.createElement(
        PetAbility,
        {
            PetModel = model,
            Callback = callback
        }
    )
    local handle = Roact.mount(element, abilities)
    return function()
        Roact.unmount(handle)
    end, function(time)
        for i = 0, time, .03 do
            wait(.03)
            Roact.update(
                handle,
                Roact.createElement(
                    PetAbility,
                    {
                        PetModel = model,
                        Callback = callback,
                        BackgroundTransparency = 1 - i / time
                    }
                )
            )
        end
        Roact.update(
            handle,
            Roact.createElement(
                PetAbility,
                {
                    PetModel = model,
                    Callback = callback,
                    BackgroundTransparency = 0
                }
            )
        )
    end
end
