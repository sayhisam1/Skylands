local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)

local MainMenuButton = require(script.MainMenuButton)
local MainMenu = Roact.Component:extend("MainMenu")
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local Background = require(script:WaitForChild("Background"))

local shopkeepAnimationId = "rbxassetid://4850764165"
local shopkeepAnimation = Instance.new("Animation")
shopkeepAnimation.AnimationId = shopkeepAnimationId

local shopkeepOverlayTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function MainMenu:render()
    local shopkeepOverlay = self.props.shopkeepOverlayController:GetViewportFrame()
    local shopkeepCam = self.props.shopkeepOverlayController:GetCamera()
    local shopkeepOverlayTween =
        TweenService:Create(
        shopkeepOverlay,
        shopkeepOverlayTweenInfo,
        {
            Position = UDim2.new(0.25, 0, .1, 0)
        }
    )
    local shopkeepCamTween =
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

    local selectNext = function()
        self:setState(
            {
                [AnimatedContainer.Damping] = 1,
                [AnimatedContainer.Frequency] = 2,
                [AnimatedContainer.Targets] = {
                    Position = UDim2.new(-2, 0, .5, 0)
                }
            }
        )
        wait(.3)
    end
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .8,
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 2,
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or
                {
                    Position = UDim2.new(.5, 0, .5, 0)
                },
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(-2, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1
        },
        {
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
                    [Roact.Event.MouseButton1Click] = function()
                        selectNext()
                        local PickaxesMenu = require(script.Parent:WaitForChild("Pickaxes"))
                        self.props.selectMenu(PickaxesMenu)
                    end,
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
                    [Roact.Event.MouseButton1Click] = function()
                        selectNext()
                        local BackpacksMenu = require(script.Parent:WaitForChild("Backpacks"))
                        self.props.selectMenu(BackpacksMenu)
                    end,
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
                    Position = UDim2.new(0.05, 0, 0.2, 0),
                    Size = UDim2.new(0, 0, .1, 0),
                    -- Event hooks --
                    [Roact.Event.MouseButton1Click] = self.props.closeGui,
                }
            ),
            Decor = Roact.createElement(Background)
        }
    )
end

return MainMenu
