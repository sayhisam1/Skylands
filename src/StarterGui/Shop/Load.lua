local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Services = require(ReplicatedStorage.Services)
local Roact = require(ReplicatedStorage.Lib.Roact)

local gui = require(script.Parent:WaitForChild("Component"))
local screenGui = script.Parent:WaitForChild("ShopScreenGui")

return function()
    Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], false)
    Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Core"], false)
    UserInputService.ModalEnabled = true
    screenGui.Enabled = true
    local handler = Roact.mount(gui, screenGui)
    return function()
        Roact.unmount(handler)
        screenGui.Enabled = false
        UserInputService.ModalEnabled = false
        Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Core"], true)
        Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], true)
    end
end
