-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local BackpackBinder = require(ReplicatedStorage.BackpackBinder)
local BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")
local Players = game:GetService("Players")
local Enums = require(ReplicatedStorage.Enums)

function Service:Load()
    local maid = self._maid
    local PlayerData = self.Services.PlayerData

    local function setupPlayer(plr)
        self:Log(2, "Setting up backpacks for", plr)
        local selectedBackpack = PlayerData:GetStore(plr, "SelectedBackpack")
        local backpackChangedConnector =
            selectedBackpack.changed:connect(
            function(new, old)
                local backpack = self:LookupBackpack(new)
                self:SetPlayerBackpack(plr, backpack)
            end
        )
        maid:GiveTask(plr.CharacterAdded:Connect(function()
            local backpack = self:LookupBackpack(selectedBackpack:getState())
            self:SetPlayerBackpack(plr, backpack)
        end))
        maid:GiveTask(
            function()
                backpackChangedConnector:disconnect()
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

local function removeBackpacks(plr)
    for _,v in pairs(plr:GetChildren()) do
        if CollectionService:HasTag(v, Enums.Tags.Backpack) then
            v:Destroy()
        end
    end
end

local function addBackpack(plr, backpack)
    local backpack = backpack:Clone()
    backpack.Parent = plr
    CollectionService:AddTag(backpack, Enums.Tags.Backpack)
end

function Service:SetPlayerBackpack(plr, backpack)
    self:Log(2, "Setting backpack", plr, backpack)
    removeBackpacks(plr)
    addBackpack(plr, backpack)
end

function Service:LookupBackpack(name)
    self:Log(1, "Looking up backpack", name)
    local backpack = BACKPACKS:FindFirstChild(name)
    return backpack
end

function Service:PromptPlayerBackpackFull(plr)
    assert(plr and plr:IsA("Player"), "Invalid player!")
    self:GetNetworkChannel():PublishPlayer(plr, "BACKPACK_FULL")
end

function Service:ValidatePlayer(plr)
    local PlayerData = self.Services.PlayerData
    local selectedBackpack = PlayerData:GetStore(plr, "SelectedBackpack")
    local ownedBackpacks = PlayerData:GetStore(plr, "OwnedBackpacks")
    if not self.TableUtil.contains(ownedBackpacks:getState(), selectedBackpack:getState()) then
        -- reset selected backpack
        PlayerData:ResetPlayerDataKey(plr, "SelectedBackpack")
    end
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
