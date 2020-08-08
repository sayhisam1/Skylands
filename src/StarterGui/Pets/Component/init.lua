-- PET MENU --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Services = require(ReplicatedStorage.Services)

local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedComponent = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedComponent)

local RootContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local IconFrame = require(ReplicatedStorage.Objects.Shared.UIComponents.IconFrame)
local Background = require(script:WaitForChild("Background"))
local Content = require(script:WaitForChild("Content"))

local gui = Roact.Component:extend("Shop")

function gui:didMount()
    -- Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], false)
    UserInputService.ModalEnabled = true
end

function gui:willUnmount()
    UserInputService.ModalEnabled = false
    -- Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], true)
end

function gui:render()
    return Roact.createElement(
        RootContainer,
        {
            [AnimatedComponent.TweenInfoOnMount] = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            [AnimatedComponent.TweenInfoOnUnmount] = TweenInfo.new(
                .3,
                Enum.EasingStyle.Linear,
                Enum.EasingDirection.Out
            ),
            [AnimatedComponent.TweenTargetsOnMount] = {
                Position = UDim2.new(.5, 0, .5, 0)
            },
            [AnimatedComponent.TweenTargetsOnUnmount] = {
                Position = UDim2.new(.5, 0, 1.5, 50)
            },
            InitialPosition = UDim2.new(.5, 0, 1.5, 50),
            Size = UDim2.new(.6, 0, .6, 0),
            Position = UDim2.new(.5, 0, .5, 0)
        },
        {
            UIAspectRatio = Roact.createElement(
                "UIAspectRatioConstraint",
                {
                    AspectRatio = 1.414
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
                "Frame",
                {
                    Size = UDim2.new(.35, 0, .15, 0),
                    Position = UDim2.new(1 - .38, 0, .06, 0),
                    BackgroundColor3 = Color3.fromRGB(110, 160, 204),
                    BorderSizePixel = 0,
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
                            Size = UDim2.new(.6, 0, .6, 0),
                            Position = UDim2.new(.05, 0, 0.1, 0),
                            Image = "http://www.roblox.com/asset/?id=5580151003",
                            ZIndex = 51
                        },
                        {
                            Slots = Roact.createElement(
                                "TextLabel",
                                {
                                    Font = Enum.Font.GothamBold,
                                    Text = "9999999",
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
                            Size = UDim2.new(.2, 0, .6, 0),
                            Position = UDim2.new(.75, 0, 0.1, 0),
                            BackgroundTransparency = 0,
                            BackgroundColor3 = Color3.fromRGB(135, 198, 254),
                            BorderSizePixel = 0,
                            Image = "rbxassetid://5585468882",
                            [Roact.Event.MouseEnter] = function(ref)
                                ref:TweenSize(
                                    UDim2.new(.22, 0, .62, 0),
                                    Enum.EasingDirection.Out,
                                    Enum.EasingStyle.Linear,
                                    .1,
                                    true
                                )
                                ref.ImageColor3 = Color3.fromRGB(255, 255, 255)
                            end,
                            [Roact.Event.MouseLeave] = function(ref)
                                ref:TweenSize(
                                    UDim2.new(.2, 0, .6, 0),
                                    Enum.EasingDirection.Out,
                                    Enum.EasingStyle.Linear,
                                    .1,
                                    true
                                )
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
                            UIAspectRatio = Roact.createElement(
                                "UIAspectRatioConstraint"
                            )
                        }
                    )
                }
            ),
            Content = Roact.createElement(Content)
        }
    )
end

return Roact.createElement(gui)
