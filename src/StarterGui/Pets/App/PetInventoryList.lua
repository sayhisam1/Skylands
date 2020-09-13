local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)

local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local PetInventoryButton = Roact.PureComponent:extend("PetInventoryButton")
local ShadowedText = require(ReplicatedStorage.Objects.Shared.UIComponents.ShadowedText)

function PetInventoryButton:render()
    local pet = self.props.Pet
    local selected = self.props.Selected
    local empty = not pet

    local children = {}
    if not empty then
        local petName = pet:GetAttribute("DisplayName") or pet:GetInstance().Name
        local viewportChildren = {
            PetName = Roact.createElement(
                ShadowedText,
                {
                    Font = Enum.Font.GothamBold,
                    Text = petName,
                    TextScaled = true,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 1,
                    Size = UDim2.new(.95, 0, .2, 0),
                    Position = UDim2.new(.5, 0, 0, 0),
                    AnchorPoint = Vector2.new(.5, 0),
                    ShadowTextColor3 = Color3.fromRGB(0, 0, 0),
                    ShadowOffset = UDim2.new(0.01, 0, 0.01, 0),
                    ZIndex = 99
                }
            )
        }
        if selected then
            viewportChildren[#viewportChildren + 1] =
                Roact.createElement(
                ShadowedText,
                {
                    Font = Enum.Font.GothamBold,
                    Text = "SELECTED",
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
        end
        children[#children + 1] = pet:MakePetViewport(viewportChildren, Color3.fromRGB(97, 140, 177))
    end

    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.ContainerType] = "TextButton",
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = Color3.fromRGB(97, 140, 177),
            Text = "",
            [Roact.Event.MouseButton1Click] = not empty and
                function()
                    self.props.setRenderedPet(
                        {
                            Pet = pet,
                            Selected = selected
                        }
                    )
                end or
                nil,
            LayoutOrder = selected and 1 or (not empty and 2 or 3)
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
            Roact.createFragment(children)
        }
    )
end

local PetInventoryList = Roact.Component:extend("PetInventoryList")

function PetInventoryList:render()
    local petComponents = {}
    local skip = (self.props.CurrentPage - 1) * 12
    local buttons = 0
    for id, v in pairs(self.props.SelectedPets) do
        skip = skip - 1
        if skip < 0 and buttons < 12 then
            buttons = buttons + 1
            petComponents[id] =
                Roact.createElement(
                PetInventoryButton,
                {
                    Pet = v,
                    setRenderedPet = self.props.setRenderedPet,
                    Selected = true
                }
            )
        end
    end
    for id, v in pairs(self.props.Pets) do
        skip = skip - 1
        if skip < 0 and buttons < 12 then
            buttons = buttons + 1
            petComponents[id] =
                Roact.createElement(
                PetInventoryButton,
                {
                    Pet = v,
                    setRenderedPet = self.props.setRenderedPet
                }
            )
        end
    end
    for i = 1, 12 - buttons do
        petComponents[i] = Roact.createElement(PetInventoryButton)
    end

    return Roact.createFragment(petComponents)
end

PetInventoryList =
    RoactRodux.connect(
    function(state)
        local numPets = state.NumPets
        local maxPetSlots = state.MaxPetStorageSlots
        local ownedPets = state.Pets
        local selectedPets = state.SelectedPets
        return {
            Pets = ownedPets,
            SelectedPets = selectedPets,
            NumEmptySlots = maxPetSlots - numPets
        }
    end
)(PetInventoryList)

return PetInventoryList
