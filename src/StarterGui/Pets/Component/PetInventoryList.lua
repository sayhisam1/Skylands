local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local ClientPlayerData = Services.ClientPlayerData
local PetStore = ClientPlayerData:GetStore("Pets")
local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)

function PetInventoryButton()
    return Roact.createElement(
        "TextButton",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(135, 198, 254),
            Text = ""
        },
        {
            UICorner = Roact.createElement(
                "UICorner",
                {
                    CornerRadius = UDim.new(.06, 0)
                }
            ),
            UIAspectRatioConstraint = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectRatio = 1,
                    AspectType = Enum.AspectType.ScaleWithParentSize,
                    DominantAxis = Enum.DominantAxis.Width
                }
            )
        }
    )
end

local PetInventoryList = Roact.Component:extend("PetInventoryList")

function PetInventoryList:render()
end

PetInventoryList = RoactRodux.connect(
    function(pets, props)
        local petComponents = {}
        for id, pet in pairs(pets) do

        end
    end
)(PetInventoryList)

return function()
    return Roact.createElement(RoactRodux.StoreProvider, {store = PetStore}, {PetList = Roact.createElement(gui)})
end
