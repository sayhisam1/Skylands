-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData", "InitializeBinders"}
Service:AddDependencies(DEPENDENCIES)

local AssetFinder = require(ReplicatedStorage.AssetFinder)
local Enums = require(ReplicatedStorage.Enums)

function Service:Load()
    local maid = self._maid
    local PlayerData = self.Services.PlayerData

    local function setupPlayer(plr)
        self:Log(2, "Setting up backpacks for", plr)
        local selectedBackpack = PlayerData:GetStore(plr, "SelectedBackpack")
        maid:GiveTask(
            selectedBackpack.changed:connect(
                function(new)
                    self:SetPlayerBackpack(plr, AssetFinder.FindBackpack(new))
                end
            )
        )
        maid:GiveTask(
            plr.CharacterAdded:Connect(
                function()
                    self:SetPlayerBackpack(plr, AssetFinder.FindBackpack(selectedBackpack:getState()))
                end
            )
        )
        self:ValidatePlayer(plr)
    end
    self:HookPlayerAction(setupPlayer)
end

local function removeBackpacks(plr)
    for _, v in pairs(plr:GetChildren()) do
        if CollectionService:HasTag(v, Enums.Tags.Backpack) then
            v:Destroy()
        end
    end
end

local function addBackpack(plr, backpack)
    backpack = backpack:Clone()
    backpack.Parent = plr
    CollectionService:AddTag(backpack, Enums.Tags.Backpack)
end

function Service:SetPlayerBackpack(plr, backpack)
    self:Log(2, "Setting backpack", plr, backpack)
    removeBackpacks(plr)
    addBackpack(plr, backpack)
end

function Service:PromptPlayerBackpackFull(plr)
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
