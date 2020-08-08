-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local PickaxeBinder = require(ReplicatedStorage.PickaxeBinder)
local PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")
local Players = game:GetService("Players")
local Enums = require(ReplicatedStorage.Enums)

function Service:Load()
    local maid = self._maid
    local PlayerData = self.Services.PlayerData

    local function setupPlayer(plr)
        self:Log(2, "Setting up pickaxe for", plr)
        local selectedPickaxe = PlayerData:GetStore(plr, "SelectedPickaxe")
        local pickaxeChangedConnector =
            selectedPickaxe.changed:connect(
            function(new, old)
                local pickaxe = self:LookupPickaxe(new)
                self:SetPlayerPickaxe(plr, pickaxe)
            end
        )
        maid:GiveTask(
            function()
                pickaxeChangedConnector:disconnect()
            end
        )
        self:ValidatePlayer(plr)
    end
    for _, plr in pairs(Players:GetPlayers()) do
        setupPlayer(plr)
    end
    maid:GiveTask(
        Players.PlayerAdded:Connect(
            function(plr)
                setupPlayer(plr)
            end
        )
    )
end

local function removePickaxes(plr)
    local starterGear = plr.StarterGear
    for _, v in pairs(starterGear:GetChildren()) do
        v:Destroy()
    end
    local char = plr.Character
    if char then
        local hum = char:FindFirstChild("Humanoid")
        if hum then
            hum:UnequipTools()
        end
    end
    for _, v in pairs(plr.Backpack:GetChildren()) do
        v:Destroy()
    end
end

local function addPickaxe(plr, pickaxe)
    CollectionService:AddTag(pickaxe, Enums.Tags.Pickaxe)
    local backpack = plr.Backpack
    pickaxe:Clone().Parent = backpack
    local starterGear = plr.StarterGear
    pickaxe:Clone().Parent = starterGear
end

function Service:SetPlayerPickaxe(plr, pickaxe)
    self:Log(2, "SETTING PICKAXE", plr, pickaxe)
    removePickaxes(plr)
    addPickaxe(plr, pickaxe)
end

function Service:LookupPickaxe(name)
    self:Log(1, "Looking up pickaxe", name)
    local pickaxe = PICKAXES:FindFirstChild(name)
    return pickaxe
end

function Service:ValidatePlayer(plr)
    local PlayerData = self.Services.PlayerData
    local selectedPickaxe = PlayerData:GetStore(plr, "SelectedPickaxe")
    local ownedPickaxes = PlayerData:GetStore(plr, "OwnedPickaxes")
    if not self.TableUtil.contains(ownedPickaxes:getState(), selectedPickaxe:getState()) then
        -- reset selected pickaxe
        PlayerData:ResetPlayerDataKey(plr, "SelectedPickaxe")
    end
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
