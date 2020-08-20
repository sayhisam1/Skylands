local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local ClientPlayerData = Services.ClientPlayerData
local PetStore = ClientPlayerData:GetStore("Pets")
local MaxSelectedPetsStore = ClientPlayerData:GetStore("MaxSelectedPets")

local Roact = require(ReplicatedStorage.Lib.Roact)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local PetInventoryList = require(script.Parent:WaitForChild("PetInventoryList"))
local PetViewport = require(script.Parent:WaitForChild("PetViewport"))

local PetContentComponent = Roact.Component:extend("PetContent")

function PetContentComponent:init()
    self:setState(
        {
            renderedPet = nil
        }
    )
end


local function getNumSelectedPets()
    local pets = PetStore:getState()
    local selected = 0
    for _, v in pairs(pets) do
        if v.Selected then
            selected = selected + 1
        end
    end
    return selected
end

function PetContentComponent:render()
    local function setPetViewport(petData)
        self:setState(
            {
                renderedPet = petData
            }
        )
    end
    return Roact.createFragment(
        {
            Content = Roact.createElement(
                "Frame",
                {
                    Position = UDim2.new(.03, 0, .17, 0),
                    Size = UDim2.new(.94, 0, .79, 0),
                    BackgroundColor3 = Color3.fromRGB(110, 160, 204),
                    BorderSizePixel = 0,
                    ZIndex = 20
                },
                {
                    UICorner = Roact.createElement(
                        "UICorner",
                        {
                            CornerRadius = UDim.new(.06, 0)
                        }
                    ),
                    SelectedPets = Roact.createElement(
                        "Frame",
                        {
                            Size = UDim2.new(.25, 0, .21, 0),
                            Position = UDim2.new(0.01, 0, 0.01, 0),
                            BackgroundColor3 = Color3.fromRGB(110, 160, 204),
                            BorderSizePixel = 1,
                            ZIndex = 10
                        },
                        {
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(.2, 0)
                                }
                            ),
                            Roact.createElement(
                                IconFrame,
                                {
                                    Size = UDim2.new(.7, 0, .7, 0),
                                    Position = UDim2.new(0.5, 0, .5, 0),
                                    AnchorPoint = Vector2.new(.5, .5),
                                    Image = "http://www.roblox.com/asset/?id=5580190056",
                                    ZIndex = 51
                                },
                                {
                                    Slots = Roact.createElement(
                                        "TextLabel",
                                        {
                                            Font = Enum.Font.GothamBold,
                                            Text = string.format("%d/%d", getNumSelectedPets(), MaxSelectedPetsStore:getState()),
                                            TextScaled = true,
                                            BackgroundTransparency = 1,
                                            TextColor3 = Color3.new(1, 1, 1),
                                            Size = UDim2.new(1, 0, 1, 0),
                                            ZIndex = 52
                                        }
                                    )
                                }
                            ),
                            Roact.createElement(
                                "ImageButton",
                                {
                                    ZIndex = 52,
                                    Size = UDim2.new(.5, 0, .5, 0),
                                    Position = UDim2.new(1, 0, .5, 0),
                                    AnchorPoint = Vector2.new(0, .5),
                                    BackgroundTransparency = 0,
                                    BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                                    BorderSizePixel = 0,
                                    Image = "rbxassetid://5585468882",
                                    [Roact.Event.MouseEnter] = function(ref)
                                        ref:TweenSize(UDim2.new(.53, 0, .53, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                                        ref.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                    end,
                                    [Roact.Event.MouseLeave] = function(ref)
                                        ref:TweenSize(UDim2.new(.5, 0, .5, 0), Enum.EasingDirection.Out, Enum.EasingStyle.Linear, .1, true)
                                        ref.ImageColor3 = Color3.fromRGB(255, 255, 255)
                                    end
                                },
                                {
                                    UICorner = Roact.createElement(
                                        "UICorner",
                                        {
                                            CornerRadius = UDim.new(.2, 0)
                                        }
                                    ),
                                    UIAspectRatio = Roact.createElement("UIAspectRatioConstraint")
                                }
                            )
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
                                    setPetViewport = setPetViewport
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
                                    Data = self.state.renderedPet
                                }
                            ),
                            UICorner = Roact.createElement(
                                "UICorner",
                                {
                                    CornerRadius = UDim.new(.1, 0)
                                }
                            ),
                        }
                    )
                }
            )
        }
    )
end

return PetContentComponent
