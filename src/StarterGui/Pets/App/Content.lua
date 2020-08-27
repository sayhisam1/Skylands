local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local PetInventoryList = require(script.Parent:WaitForChild("PetInventoryList"))
local PetViewport = require(script.Parent:WaitForChild("PetViewport"))
local PetIndicatorButton = require(script.Parent:WaitForChild("PetIndicatorButton"))

local PetContentComponent = Roact.Component:extend("PetContent")

function PetContentComponent:init()
    self:setState(
        {
            renderedPetId = 0
        }
    )
end

function PetContentComponent:render()
    local function setRenderedPet(data)
        self:setState(
            {
                renderedPet = data
            }
        )
    end
    return Roact.createFragment(
        {
            Content = Roact.createElement(
                "ImageLabel",
                {
                    Position = self.props.Position,
                    Size = self.props.Size,
                    BackgroundColor3 = Color3.fromRGB(110, 160, 204),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 20,
                    ScaleType = Enum.ScaleType.Tile,
                    TileSize = UDim2.new(0, 64, 0, 64),
                    Image = "rbxassetid://4651117489",
                    ImageColor3 = Color3.fromRGB(110, 160, 204)
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    ),
                    NumSelectedPets = Roact.createElement(
                        PetIndicatorButton,
                        {
                            Size = UDim2.new(.25, 0, .2, 0),
                            Position = UDim2.new(0.03, 0, 0.01, 0),
                            BackgroundColor3 = Color3.fromRGB(110, 160, 204),
                            Image = "http://www.roblox.com/asset/?id=5580190056",
                            TextGetter = function(state)
                                return string.format("%d/%d", state.NumSelectedPets, state.MaxSelectedPets)
                            end
                        }
                    ),
                    PetList = Roact.createElement(
                        "ScrollingFrame",
                        {
                            BackgroundTransparency = 1,
                            Size = UDim2.new(.6, 0, .7, 0),
                            Position = UDim2.new(0.03, 0, 0.25, 0),
                            BorderSizePixel = 0
                        },
                        {
                            UIGrid = Roact.createElement(
                                "UIGridLayout",
                                {
                                    CellSize = UDim2.new(0, 100, 0, 100),
                                    CellPadding = UDim2.new(0, 5, 0, 5),
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }
                            ),
                            PetList = Roact.createElement(
                                PetInventoryList,
                                {
                                    setRenderedPet = setRenderedPet
                                }
                            )
                        }
                    ),
                    PetViewport = Roact.createElement(
                        "Frame",
                        {
                            Size = UDim2.new(.32, 0, .9, 0),
                            Position = UDim2.new(.65, 0, .05, 0),
                            BackgroundColor3 = Color3.fromRGB(97, 140, 177),
                            BorderSizePixel = 0
                        },
                        {
                            Viewport = Roact.createElement(
                                PetViewport,
                                {
                                    renderedPet = self.state.renderedPet,
                                    makePopup = self.props.makePopup,
                                    setRenderedPet = setRenderedPet,
                                }
                            ),
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(.1, 0)
                                }
                            )
                        }
                    )
                }
            )
        }
    )
end

return PetContentComponent
