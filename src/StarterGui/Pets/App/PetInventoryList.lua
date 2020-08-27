local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)

local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local PetInventoryButton = Roact.PureComponent:extend("PetInventoryButton")
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

local AssetFinder = require(ReplicatedStorage.AssetFinder)

function PetInventoryButton:render()
    local petData = self.props.petData
    local empty = not petData.PetClass

    local viewportContainer =
        not empty and
        Roact.createElement(
            ViewportContainer,
            {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(.5, 0, .5, 0),
                AnchorPoint = Vector2.new(.5, .5),
                RenderedModel = not empty and AssetFinder.FindPet(petData.PetClass),
                CameraCFrame = CFrame.new(0, 0, 1) * CFrame.Angles(math.pi / 4, math.pi / 4, math.pi / 4),
                ZIndex = 22
            },
            {
                PetName = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = petData.PetClass,
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.new(1, 1, 1),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, .2, 0),
                        Position = UDim2.new(.5, 0, 0, 0),
                        AnchorPoint = Vector2.new(.5, 0),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 1
                    }
                ),
                SelectText = Roact.createElement(
                    ShadowedText,
                    {
                        Font = Enum.Font.GothamBold,
                        Text = petData.Selected and "SELECTED" or "",
                        TextScaled = true,
                        BackgroundTransparency = 1,
                        TextColor3 = Color3.fromRGB(85, 109, 248),
                        TextStrokeTransparency = 1,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(.5, 0, 0.5, 0),
                        AnchorPoint = Vector2.new(.5, .5),
                        ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                        ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                        ZIndex = 100,
                        Rotation = -20
                    }
                )
            }
        )
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.ContainerType] = "TextButton",
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(97, 140, 177),
            Text = "",
            [Roact.Event.MouseButton1Click] = not empty and function()
                    self.props.setRenderedPet(petData)
                end or nil,
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
                    AspectType = Enum.AspectType.ScaleWithParentSize
                }
            ),
            viewportContainer
        }
    )
end

local PetInventoryList = Roact.Component:extend("PetInventoryList")

function PetInventoryList:render()
    local petComponents = {}
    for id, v in pairs(self.props.Pets) do
        petComponents[id] =
            Roact.createElement(
            PetInventoryButton,
            {
                petData = v,
                setRenderedPet = self.props.setRenderedPet
            }
        )
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
            Pets = pets
        }
    end
)(PetInventoryList)

return PetInventoryList
