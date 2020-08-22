-- PET MENU --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Services = require(ReplicatedStorage.Services)
local ClientPlayerData = Services.ClientPlayerData
local GuiController = Services.GuiController
local PetStore = ClientPlayerData:GetStore("Pets")
local StorageSlotsStore = ClientPlayerData:GetStore("MaxPetStorageSlots")

local Roact = require(ReplicatedStorage.Lib.Roact)
local RoactRodux = require(ReplicatedStorage.Lib.RoactRodux)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)

local Background = require(script:WaitForChild("Background"))
local Content = require(script:WaitForChild("Content"))
local PetIndicatorButton = require(script:WaitForChild("PetIndicatorButton"))
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local gui = Roact.Component:extend("Shop")

function gui:didMount()
    GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], false)
    UserInputService.ModalEnabled = true
end

function gui:willUnmount()
    UserInputService.ModalEnabled = false
    GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], true)
end

function gui:render()
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .8,
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 2,
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or {
                Position = UDim2.new(.5, 0, .5, 0)
            },
            AnchorPoint = Vector2.new(.5, .5),
            Size = UDim2.new(0.5, 0, 0.5, 0),
            Position = UDim2.new(0.5, 0, 1.5, 0),
            BackgroundTransparency = 1,
        },
        {
            UIAspectRatio = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectRatio = 1.39
                }
            ),
            Background = Roact.createElement(Background),
            Title = Roact.createElement(
                "TextLabel",
                {
                    Font = Enum.Font.GothamBold,
                    Text = "PET INVENTORY",
                    TextScaled = true,
                    BackgroundTransparency = 1,
                    TextColor3 = Color3.new(1, 1, 1),
                    TextStrokeColor3 = Color3.new(1, 1, 1),
                    TextStrokeTransparency = 0,
                    Size = UDim2.new(.58, 0, .14, 0),
                    Position = UDim2.new(.03, 0, 0.01, 0),
                    ZIndex = 10
                }
            ),
            PetStorageSlots = Roact.createElement(
                PetIndicatorButton,
                {
                    store = StorageSlotsStore,
                    TextGetter = function(val)
                        return string.format("%d/%d", TableUtil.len(PetStore:getState() or {}), (type(val) == "number" and val) or 0)
                    end,
                    Image = "http://www.roblox.com/asset/?id=5580151003",
                    Size = UDim2.new(.2, 0, .1, 0),
                    Position = UDim2.new(.9, 0, .1, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Color3.fromRGB(110, 160, 204)
                }
            ),
            Content = Roact.createElement(
                Content,
                {
                    Position = UDim2.new(.03, 0, .17, 0),
                    Size = UDim2.new(.94, 0, .79, 0)
                }
            ),
            CloseButton = Roact.createElement(
                "ImageButton",
                {
                    Size = UDim2.new(.1, 0, .1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    AnchorPoint = Vector2.new(1, 0),
                    ZIndex = 100,
                    Image = "http://www.roblox.com/asset/?id=5589393189",
                    BackgroundTransparency = 1,
                    [Roact.Event.MouseButton1Down] = function()
                        self:setState({
                            [AnimatedContainer.Damping] = 1,
                            [AnimatedContainer.Frequency] = 2,
                            [AnimatedContainer.Targets] = {
                                Position = UDim2.new(.5, 0, 1.5, 0)
                            },
                        })
                        wait(.3)
                        GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS["Pets"], false)
                    end
                },
                {
                    UIAspectRatio = Roact.createElement(
                        "UIAspectRatioConstraint",
                        {
                            AspectRatio = 1
                        }
                    )
                }
            )
        }
    )
end

return Roact.createElement(RoactRodux.StoreProvider, {store = PetStore}, {App = Roact.createElement(gui)})
