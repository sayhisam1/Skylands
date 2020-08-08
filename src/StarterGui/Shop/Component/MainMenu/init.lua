local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)

local MainMenuButton = require(script.MainMenuButton)
local MainMenu = Roact.Component:extend("MainMenu")
local RootContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local AnimatedComponent = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedComponent)
local Background = require(script:WaitForChild("Background"))

local shopkeepAnimationId = "rbxassetid://4850764165"
local shopkeepAnimation = Instance.new("Animation")
shopkeepAnimation.AnimationId = shopkeepAnimationId

local shopkeepOverlayTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function MainMenu:render()
    local shopkeepOverlay = self.props.shopkeepOverlayController:GetViewportFrame()
    local shopkeepCam = self.props.shopkeepOverlayController:GetCamera()
    shopkeepOverlayTween =
        TweenService:Create(
        shopkeepOverlay,
        shopkeepOverlayTweenInfo,
        {
            Position = UDim2.new(0.25, 0, .1, 0)
        }
    )
    shopkeepCamTween =
        TweenService:Create(
        shopkeepCam,
        shopkeepOverlayTweenInfo,
        {
            CFrame = self.props.shopkeepOverlayController:GetCameraCFrame(Vector3.new(0, 2, -3), Vector3.new(0, 2, 0))
        }
    )
    shopkeepOverlayTween:Play()
    shopkeepCamTween:Play()
    self.props.shopkeepOverlayController:PlayAnimation(shopkeepAnimation)
    return Roact.createElement(
        RootContainer,
        {
            ClipsDescendants = true,
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
                Position = UDim2.new(-.5, 0, .5, 0)
            },
            InitialPosition = UDim2.new(-.5, 0, .5, 0),
            [Roact.Children] = {
                Pickaxes = Roact.createElement(
                    MainMenuButton,
                    {
                        IconProps = {
                            Image = "rbxgameasset://Images/pickaxe",
                            ImageColor3 = Color3.fromRGB(0, 0, 0)
                        },
                        TextProps = {
                            Text = "Pickaxes",
                            Font = Enum.Font.GothamBold
                        },
                        Position = UDim2.new(0.1, 0, 0.6, 0),
                        Size = UDim2.new(0, 0, .2, 0),
                        -- Event hooks --
                        [Roact.Event.MouseButton1Click] = function()
                            local PickaxesMenu = require(script.Parent:WaitForChild("Pickaxes"))
                            self.props.selectMenuCallback(PickaxesMenu)
                        end,
                        [Roact.Event.MouseEnter] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .22, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        end,
                        [Roact.Event.MouseLeave] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .2, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    }
                ),
                Backpacks = Roact.createElement(
                    MainMenuButton,
                    {
                        IconProps = {
                            Image = "rbxassetid://5572289405",
                            ImageColor3 = Color3.fromRGB(0, 0, 0)
                        },
                        TextProps = {
                            Text = "Backpacks",
                            Font = Enum.Font.GothamBold
                        },
                        Position = UDim2.new(0.1, 0, 0.35, 0),
                        Size = UDim2.new(0, 0, .2, 0),
                        -- Event hooks --
                        [Roact.Event.MouseButton1Click] = function()
                            local BackpacksMenu = require(script.Parent:WaitForChild("Backpacks"))
                            self.props.selectMenuCallback(BackpacksMenu)
                        end,
                        [Roact.Event.MouseEnter] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .22, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        end,
                        [Roact.Event.MouseLeave] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .2, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    }
                ),
                Close = Roact.createElement(
                    MainMenuButton,
                    {
                        IconProps = {
                            Image = "rbxassetid://5423238056",
                            ImageColor3 = Color3.fromRGB(0, 0, 0)
                        },
                        TextProps = {
                            Text = "Close",
                            Font = Enum.Font.GothamBold
                        },
                        Position = UDim2.new(0.05, 0, 0.1, 0),
                        Size = UDim2.new(0, 0, .1, 0),
                        -- Event hooks --
                        [Roact.Event.MouseButton1Click] = function()
                            local Services = require(ReplicatedStorage.Services)
                            Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Shop"], false)
                        end,
                        [Roact.Event.MouseEnter] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .11, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
                        end,
                        [Roact.Event.MouseLeave] = function(ref)
                            ref:TweenSize(
                                UDim2.new(0, 0, .1, 0),
                                Enum.EasingDirection.Out,
                                Enum.EasingStyle.Linear,
                                .1,
                                true
                            )
                            ref.Icon.ImageColor3 = Color3.fromRGB(0, 0, 0)
                        end
                    }
                ),
                Decor = Roact.createElement(Background)
            }
        }
    )
end

return MainMenu
