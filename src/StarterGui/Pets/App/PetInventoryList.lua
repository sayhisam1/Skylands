local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)

local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local PetInventoryButton = Roact.PureComponent:extend("PetInventoryButton")
function PetInventoryButton:render()
    local petData = self.props.petData
    local empty = not petData
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.ContainerType] = "TextButton",
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(97, 140, 177),
            Text = "",
            [Roact.Event.MouseButton1Click] = not empty and function()
                    self.props.select(petData.Id)
                end,
            LayoutOrder = (not empty and (petData.Selected and 1 or 2)) or 3
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
            ),
            (self.props[Roact.Children] and self.props[Roact.Children].Thumbnail)
        }
    )
end

local PetInventoryList = Roact.Component:extend("PetInventoryList")

function PetInventoryList:render()
    local petComponents = {}
    for id, v in pairs(self.props.Pets) do
        if v.PetClass then
            petComponents[id] =
                Roact.createElement(
                PetInventoryButton,
                {
                    petData = v,
                    select = self.props.updateRenderedPetId
                },
                self.props.PetComponents[id]
            )
        else
            petComponents[id] =
                Roact.createElement(
                PetInventoryButton,
                {
                    petData = v,
                    select = self.props.updateRenderedPetId
                }
            )
        end
    end
    return Roact.createFragment(petComponents)
end

PetInventoryList =
    RoactRodux.connect(
    function(state, props)
        local numPets = state.NumPets
        local maxPetSlots = state.MaxPetStorageSlots
        local pets = {}
        for k, v in pairs(state.Pets) do
            pets[k] = v
        end
        for i = 1, maxPetSlots - numPets do
            pets[i] = {}
        end

        return {
            Pets = pets,
            PetComponents = state.PetComponents
        }
    end
)(PetInventoryList)

return PetInventoryList
