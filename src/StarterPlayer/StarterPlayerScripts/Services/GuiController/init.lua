-- stores player inventories --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"ClientPlayerData"}
Service:AddDependencies(DEPENDENCIES)

local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local StarterGui = game:GetService("StarterGui")
local PlayerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
local CoinRain = require(script.CoinRain)
local ADMINS = require(ReplicatedStorage.AdminDictionary)

Service.GUI_GROUPS = {
    Gameplay = {
        "Sidebar",
        "DepthGui",
        "BlockIndicator"
    },
    Shop = {
        "Shop"
    },
    Pets = {
        "Pets"
    },
    Core = {}
}

function Service:Load()
    local maid = self._maid
    local plr = game.Players.LocalPlayer
    if self.TableUtil.contains(ADMINS, plr.UserId) then
        local Cmdr = require(ReplicatedStorage:WaitForChild("CmdrClient"))
        Cmdr:SetActivationKeys({Enum.KeyCode.Semicolon})
    end

    local backpack_channel = self:GetServerNetworkChannel("BackpackService")
    maid:GiveTask(
        backpack_channel:Subscribe(
            "BACKPACK_FULL",
            function()
                self:PromptBackpackFull()
            end
        )
    )

    local ClientPlayerData = self.Services.ClientPlayerData
    local coinStore = ClientPlayerData:GetStore("Gold")
    maid:GiveTask(
        coinStore.changed:connect(
            function(new, old)
                CoinRain:Run(game.Players.LocalPlayer)
            end
        )
    )

    local function resetGuis()
        for _, v in pairs(self.GUI_GROUPS) do
            self:SetGuiGroupVisible(v, false)
        end
        self:SetGuiGroupVisible(self.GUI_GROUPS["Gameplay"], true)
        self:SetGuiGroupVisible(self.GUI_GROUPS["Core"], true)
    end
    resetGuis()
    maid:GiveTask(Players.LocalPlayer.CharacterAdded:Connect(resetGuis))
end

function Service:Unload()
    self._maid:Destroy()
    PlayerGui:ClearAllChildren()
end

function Service:PromptBackpackFull()
    local backpackFullGui = PlayerGui:FindFirstChild("BackpackFull")
    if not backpackFullGui.Enabled then
        backpackFullGui.Enabled = true
    end
end

function Service:_getGuiMaid(name)
    if not self._maids then
        self._maids = {}
    end
    if not self._maids[name] then
        self._maids[name] = Maid.new()
    end
    return self._maids[name]
end

function Service:SetGuiVisible(gui_name, visible)
    local maid = self:_getGuiMaid(gui_name)
    if visible and maid["Close"] then
        return
    end
    maid:Destroy()
    if not visible then
        return
    end
    local gui = PlayerGui:WaitForChild(gui_name, 5)
    assert(gui, "Invalid gui_name " .. gui_name)
    if gui:FindFirstChild("Load") then
        maid["Close"] = require(gui:FindFirstChild("Load"))()
    else
        gui.Enabled = true
        maid["Close"] = function()
            gui.Enabled = false
        end
    end
end

function Service:SetGuiGroupVisible(group, visible)
    for _, v in pairs(group) do
        self:SetGuiVisible(v, visible)
    end
    if group == self.GUI_GROUPS.Core then
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, visible)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, visible)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, visible)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, visible)
    end
end

return Service
