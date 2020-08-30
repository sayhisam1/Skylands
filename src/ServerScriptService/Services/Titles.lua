-- stores player inventories --

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local AssetFinder = require(ReplicatedStorage.AssetFinder)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)
local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)

local currentPlayerTitles = {}
function Service:Load()
    local maid = self._maid
    self:HookPlayerAction(function(plr)
        local event = plr.CharacterAdded:Connect(function()
            self:GiveTitle(plr)
        end)
        local totalOresMined = self.Services.PlayerData:GetStore(plr, "TotalOresMined")
        local event2 = totalOresMined.changed:connect(function(new, old)
            self:GiveTitle(plr)
        end)
        maid[plr] = function()
            event:Disconnect()
            event2:disconnect()
        end
    end)
end

function Service:GiveTitle(plr)
    local totalOresMined = self.Services.PlayerData:GetStore(plr, "TotalOresMined"):getState()

    local title = AssetFinder.GetTitleForCount(totalOresMined)
    if currentPlayerTitles[plr] == title then
        return
    end
    currentPlayerTitles[plr] = title
    local promise = GetPlayerCharacterWorkspace(plr):andThen(function(char)
        local _, primaryPart = GetPrimaryPart(char):awaitStatus()
        for _, v in pairs(char:GetDescendants()) do
            if CollectionService:HasTag(v, self.Enums.Tags.Title) then
                v:Destroy()
            end
        end
        local head = char:FindFirstChild("Head")
        local newGui = title:Clone()
        local playername = newGui.Playername
        playername.Text = plr.Name
        newGui.Adornee = head
        newGui.Parent = primaryPart
    end)
end

return Service