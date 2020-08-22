local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Services = require(ReplicatedStorage.Services)
local GuiController = Services.GuiController

local Roact = require(ReplicatedStorage.Lib.Roact)
local AnimatedContainer = require(ReplicatedStorage.Objects.Shared.UIComponents.AnimatedContainer)
local Null = require(ReplicatedStorage.Objects.Shared.Null)

local Background = require(script:WaitForChild("Background"))
local MainMenu = require(script:WaitForChild("MainMenu"))

local ShopkeepOverlay = script.Parent:WaitForChild("ShopkeepOverlay")
ShopkeepOverlay.Visible = false

local gui = Roact.Component:extend("Shop")

function gui:init()
    local overlayClone = Null
    local controller = Null
    if RunService:IsRunning() then
        overlayClone = ShopkeepOverlay:Clone()
        overlayClone.Parent = script.Parent:WaitForChild("ShopScreenGui")
        controller = require(overlayClone:WaitForChild("Controller"))
    end

    self.ref = Roact.createRef()
    self:setState(
        {
            selectedMenu = MainMenu,
            shopkeepOverlay = overlayClone,
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
    local closeGui = function()
        self:setState({
            [AnimatedContainer.Damping] = 1,
            [AnimatedContainer.Frequency] = 2,
            [AnimatedContainer.Targets] = {
                Position = UDim2.new(.5, 0, 2, 0)
            },
        })
        wait(.5)
        GuiController:SetGuiGroupVisible(GuiController.GUI_GROUPS.Shop, false)
    end
    local selectMenu = function(new_menu)
        self:setState(
            {
                selectedMenu = new_menu
            }
        )
    end
    return Roact.createElement(
        AnimatedContainer,
        {
            [AnimatedContainer.Damping] = self.state[AnimatedContainer.Damping] or .8,
            [AnimatedContainer.Frequency] = self.state[AnimatedContainer.Frequency] or 2,
            [AnimatedContainer.Targets] = self.state[AnimatedContainer.Targets] or {
                Position = UDim2.new(.5, 0, .5, 0)
            },
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(.5, 0, 2, 0),
            AnchorPoint = Vector2.new(.5, .5),
            BackgroundTransparency = 1,
        },
        {
            Decor = Roact.createElement(Background),
            Menu = Roact.createElement(
                self.state.selectedMenu,
                {
                    closeGui = closeGui,
                    selectMenu = selectMenu,
                    shopkeepOverlayController = self.state.shopkeepController
                }
            )
        }
    )
end

return Roact.createElement(gui)
