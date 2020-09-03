local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Roact = require(ReplicatedStorage.Lib.Roact)
local PetInventoryList = require(script.Parent:WaitForChild("PetInventoryList"))
local PetViewport = require(script.Parent:WaitForChild("PetViewport"))
local PetIndicatorButton = require(script.Parent:WaitForChild("PetIndicatorButton"))
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local PetContentComponent = Roact.Component:extend("PetContent")
local PageSelector = require(script.Parent.PageSelector)
function PetContentComponent:init()
    self:setState(
        {
            renderedPetId = 0,
            currentPage = 1
        }
    )
end

function PetContentComponent:render()
    local function setRenderedPet(data)
        self:setState(
            {
                renderedPet = data or Roact.None
            }
        )
    end
    local function setCurrentPage(pagenum)
        self:setState(
            {
                currentPage = pagenum
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
                            Image = "rbxassetid://5644766906",
                            TextGetter = function(state)
                                return string.format("%d/%d", state.NumSelectedPets, state.MaxSelectedPets)
                            end
                        }
                    ),
                    PageSelection = Roact.createElement(
                        "Frame",
                        {
                            Size = UDim2.new(.25, 0, .2, 0),
                            Position = UDim2.new(0.3, 0, 0.01, 0),
                            BackgroundTransparency = 1,
                        },
                        {
                            Roact.createElement(PageSelector, {
                                setCurrentPage = setCurrentPage,
                                CurrentPage = self.state.currentPage
                            })
                        }
                    ),
                    PetList = Roact.createElement(
                        "Frame",
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
                                    CellSize = UDim2.new(.21, 0, .3, 0),
                                    CellPadding = UDim2.new(.01, 0, 0.01, 0),
                                    SortOrder = Enum.SortOrder.LayoutOrder
                                }
                            ),
                            PetList = Roact.createElement(
                                PetInventoryList,
                                {
                                    setRenderedPet = setRenderedPet,
                                    CurrentPage = self.state.currentPage
                                }
                            )
                        }
                    ),
                    PetViewport = Roact.createElement(
                        AnimatedContainer,
                        {
                            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .7,
                            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 2,
                            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or
                                {
                                    Size = self.state.renderedPet and UDim2.new(.32, 0, .9, 0) or UDim2.new(0,0,0,0),
                                },
                            Position = UDim2.new(.65, 0, .05, 0),
                            Size = self.state.renderedPet and UDim2.new(0, 0, 0, 0) or UDim2.new(.32, 0, .9, 0),
                            BackgroundTransparency = 1,
                        },
                        {
                            Viewport = Roact.createElement(
                                PetViewport,
                                {
                                    renderedPet = self.state.renderedPet,
                                    makePopup = self.props.makePopup,
                                    setRenderedPet = setRenderedPet
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
