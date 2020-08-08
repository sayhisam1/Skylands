local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Services = require(ReplicatedStorage.Services)

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedComponent = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedComponent)
local Null = require(ReplicatedStorage.Objects.Shared.Null)

local RootContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local Background = require(script:WaitForChild("Background"))
local MainMenu = require(script:WaitForChild("MainMenu"))

local ShopkeepOverlay = script.Parent:WaitForChild("ShopkeepOverlay")
ShopkeepOverlay.Visible = false

local gui = Roact.Component:extend("Shop")

function gui:init()
    local overlayClone = Null
    local controller = Null
    if RunService:IsRunning() then
        overlayclone = ShopkeepOverlay:Clone()
        overlayclone.Parent = script.Parent:WaitForChild("ShopScreenGui")
        controller = require(overlayclone:WaitForChild("Controller"))
    end

    self.ref = Roact.createRef()
    self:setState(
        {
            selectedMenu = MainMenu,
            shopkeepOverlay = overlayclone,
            shopkeepController = controller
        }
    )
end

local shopMusic = Instance.new("Sound")
shopMusic.Name = "ShopMusic"
shopMusic.SoundId = "rbxassetid://1844697612"
function gui:didMount()
    UserInputService.ModalEnabled = true
    Services.MusicController:PushMusic(shopMusic)
    local shopkeepOverlay = self.state.shopkeepOverlay
    shopkeepOverlay.Visible = true
end

function gui:willUnmount()
    Services.ShopController:ResetLastShopCloseTime()
    UserInputService.ModalEnabled = false
    Services.MusicController:PopMusic()
    local shopkeepOverlay = self.state.shopkeepOverlay
    shopkeepOverlay.Visible = false
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
        },
        {
            Decor = Roact.createElement(Background),
            Menu = Roact.createElement(
                self.state.selectedMenu,
                {
                    selectMenuCallback = function(new_menu)
                        self:setState(
                            {
                                selectedMenu = new_menu
                            }
                        )
                    end,
                    shopkeepOverlayController = self.state.shopkeepController
                }
            )
        }
    )
end

return Roact.createElement(gui)
