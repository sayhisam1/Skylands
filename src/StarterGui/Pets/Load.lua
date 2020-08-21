local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)
local Roact = require(ReplicatedStorage.Lib.Roact)

local gui = require(script.Parent:WaitForChild("App"))
local screenGui = script.Parent:WaitForChild("PetScreenGui")

return function()
    Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], false)
    screenGui.Enabled = true
    local handler = Roact.mount(gui, screenGui)
    return function()
        Roact.unmount(handler)
        screenGui.Enabled = false
        Services.GuiController:SetGuiGroupVisible(Services.GuiController.GUI_GROUPS["Gameplay"], true)
    end
end