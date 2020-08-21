local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local ViewportContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.ViewportContainer)
local AssetFinder = require(ReplicatedStorage.AssetFinder)

local PetInventoryButton = Roact.PureComponent:extend("PetInventoryButton")

function PetInventoryButton:render()
    local data = self.props.Data
    local viewportContainer =
        Roact.createElement(
        "Frame",
        {
            BackgroundTransparency = 1
        }
    )
    if data then
        viewportContainer =
            Roact.createElement(
            ViewportContainer,
            {
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(.5, 0, .5, 0),
                AnchorPoint = Vector2.new(.5, .5),
                RenderedModel = AssetFinder.FindPet(data.PetClass),
                CameraCFrame = CFrame.new(0, 0, 6),
                ZIndex = 22
            },
            {
                Roact.createElement("TextLabel", {
                    Text = (data.Selected and "SELECTED") or "",
                    Size = UDim2.new(1, 0, 1, 0),
                    AnchorPoint = Vector2.new(.5, .5),
                    Position = UDim2.new(.5, 0, .5, 0),
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 1,
                    Rotation = -45,
                    TextScaled = true
                })
            }
        )
    end
    return Roact.createElement(
        "TextButton",
        {
            Size = UDim2.new(1, 0, 1, 0),
            BorderSizePixel = 0,
            BackgroundColor3 = (data and self.props.highlighted and Color3.fromRGB(135, 198, 254)) or Color3.fromRGB(97, 140, 177),
            Text = "",
            [Roact.Event.MouseButton1Click] = function()
                if data then
                    self.props.select(data)
                end
            end,
            LayoutOrder = (data and data.Selected and 1) or (data and 2) or 1000
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
            Viewport = viewportContainer
        }
    )
end

local PetInventoryList = Roact.Component:extend("PetInventoryList")

function PetInventoryList:init()
    self:setState(
        {
            selectedPetId = nil
        }
    )
end

function PetInventoryList:render()
    local function selectPet(data)
        self:setState(
            {
                selectedPetId = data.Id
            }
        )
        self.props.setPetViewport(data)
    end
    local petComponents = {}
    for _, v in pairs(self.props.Pets) do
        petComponents[v.Id] =
            Roact.createElement(
            PetInventoryButton,
            {
                Data = (v.PetClass ~= nil and v) or nil,
                select = selectPet,
                highlighted = (v.Id == self.state.selectedPetId)
            }
        )
    end
    return Roact.createFragment(petComponents)
end

PetInventoryList =
    RoactRodux.connect(
    function(pets, props)
        -- ClientPlayerData:Log(3, "PET INVENTORY", pets)
        local petComponents = {}
        for id, pet in pairs(pets or {}) do
            petComponents[tostring(id)] = pet
        end
        return {
            Pets = petComponents
        }
    end
)(PetInventoryList)

return function(props)
    return Roact.createElement(PetInventoryList, props)
end
