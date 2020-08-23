local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)

local MainMenu = script.Parent:WaitForChild("MainMenu")
local MainMenuButton = require(MainMenu:WaitForChild("MainMenuButton"))
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local Background = require(script:WaitForChild("Background"))
local spr = require(ReplicatedStorage.Lib.spr)

local PickaxeList = require(script:WaitForChild("PickaxeList"))

local PickaxeMenu = Roact.Component:extend("PickaxeMenu")

local shopkeepAnimationId = "rbxassetid://5104830460"
local shopkeepAnimation = Instance.new("Animation")
shopkeepAnimation.AnimationId = shopkeepAnimationId

local shopkeepOverlayTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
function PickaxeMenu:render()
    local shopkeepOverlay = self.props.shopkeepOverlayController:GetViewportFrame()
    local shopkeepCam = self.props.shopkeepOverlayController:GetCamera()

    local shopkeepCamTween =
        TweenService:Create(
        shopkeepCam,
        shopkeepOverlayTweenInfo,
        {
            CFrame = self.props.shopkeepOverlayController:GetCameraCFrame(Vector3.new(-3.5, 0, -5.5))
        }
    )
    spr.target(shopkeepOverlay, .4, 2, {
        Position = UDim2.new(0.45, 0, 0, 0)
    })
    shopkeepCamTween:Play()
    self.props.shopkeepOverlayController:PlayAnimation(shopkeepAnimation)

    local selectNext = function()
        self:setState(
            {
                [AnimatedContainer.Damping] = 1,
                [AnimatedContainer.Frequency] = 2,
                [AnimatedContainer.Targets] = {
                    Position = UDim2.new(2, 0, .5, 0)
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
            Position = UDim2.new(2, 0, .5, 0),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1
        },
        {
            Decor = Roact.createElement(Background),
            Back = Roact.createElement(
                MainMenuButton,
                {
                    IconProps = {
                        Image = "rbxassetid://5423238056",
                        ImageColor3 = Color3.fromRGB(0, 0, 0)
                    },
                    TextProps = {
                        Text = "Back",
                        Font = Enum.Font.GothamBold
                    },
                    Position = UDim2.new(0.05, 0, 0.2, 0),
                    Size = UDim2.new(0, 0, .1, 0),
                    [Roact.Event.MouseButton1Click] = function()
                        selectNext()
                        self.props.selectMenu(require(MainMenu))
                    end
                }
            ),
            PickaxeList = Roact.createElement(PickaxeList)
        }
    )
end

return PickaxeMenu
