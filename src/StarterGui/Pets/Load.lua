local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Services = require(ReplicatedStorage.Services)
local Roact = require(ReplicatedStorage.Lib.Roact)

local gui = require(script.Parent:WaitForChild("App"))
local screenGui = script.Parent:WaitForChild("PetScreenGui")

return function()
    Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], false)
    UserInputService.ModalEnabled = true
    screenGui.Enabled = true
    local handler = Roact.mount(gui, screenGui)
    return function()
        Roact.unmount(handler)
        screenGui.Enabled = false
        UserInputService.ModalEnabled = false
        Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], true)
    end
end
