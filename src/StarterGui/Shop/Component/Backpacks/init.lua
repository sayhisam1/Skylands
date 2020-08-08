local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Services = require(ReplicatedStorage.Services)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)

local BackpackMenuButton = require(script.BackpackMenuButton)
local BackpackButtons = require(script.BackpackButtons)

local BackpackMenu = Roact.Component:extend("BackpackMenu")
local RootContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local AnimatedComponent = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedComponent)
local Background = require(script:WaitForChild("Background"))

local shopkeepAnimationId = "rbxassetid://5104830460"
local shopkeepAnimation = Instance.new("Animation")
shopkeepAnimation.AnimationId = shopkeepAnimationId

local shopkeepOverlayTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function BackpackMenu:render()
    local shopkeepOverlay = self.props.shopkeepOverlayController:GetViewportFrame()
    local shopkeepCam = self.props.shopkeepOverlayController:GetCamera()
    shopkeepOverlayTween =
        TweenService:Create(
        shopkeepOverlay,
        shopkeepOverlayTweenInfo,
        {
            Position = UDim2.new(0.45, 0, 0, 0)
        }
    )
    shopkeepCamTween =
        TweenService:Create(
        shopkeepCam,
        shopkeepOverlayTweenInfo,
        {
            CFrame = self.props.shopkeepOverlayController:GetCameraCFrame(Vector3.new(-3.5, 0, -5.5))
        }
    )
    shopkeepOverlayTween:Play()
    shopkeepCamTween:Play()
    self.props.shopkeepOverlayController:PlayAnimation(shopkeepAnimation)
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
                Position = UDim2.new(1.5, 0, .5, 0)
            },
            InitialPosition = UDim2.new(1.5, 0, .5, 0),
            [Roact.Children] = {
                Decor = Roact.createElement(Background),
                Back = Roact.createElement(
                    BackpackMenuButton,
                    {
                        IconProps = {
                            Image = "rbxassetid://5423238056",
                            ImageColor3 = Color3.fromRGB(0, 0, 0)
                        },
                        TextProps = {
                            Text = "Back",
                            Font = Enum.Font.GothamBold
                        },
                        Position = UDim2.new(0.05, 0, 0.1, 0),
                        Size = UDim2.new(0, 0, .1, 0),
                        AspectRatio = 1,
                        -- Event hooks --
                        [Roact.Event.MouseButton1Click] = function()
                            local BackpacksMenu = require(script.Parent:WaitForChild("MainMenu"))
                            self.props.selectMenuCallback(BackpacksMenu)
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
                BackpackButtons = Roact.createElement(BackpackButtons)
            }
        }
    )
end

return BackpackMenu
