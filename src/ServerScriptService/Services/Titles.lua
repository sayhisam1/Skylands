-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local MinedBlocksTitleDictionary = require(ReplicatedStorage.MinedBlocksTitleDictionary)
local GetPlayerCharacterWorkspace = require(ReplicatedStorage.Objects.Promises.GetPlayerCharacterWorkspace)
local GetPrimaryPart = require(ReplicatedStorage.Objects.Promises.GetPrimaryPart)

function Service:Load()
    local maid = self._maid
    self:HookPlayerAction(function(plr)
        maid[plr] = plr.CharacterAdded:Connect(function(char)
            self:GiveTitle(plr)
        end)
    end)
end

local defaultBillboard = Instance.new("BillboardGui")
defaultBillboard.Name = "Title"
defaultBillboard.Size = UDim2.new(6, 0, .7, 0)
defaultBillboard.SizeOffset = Vector2.new(0, 2.5)
defaultBillboard.LightInfluence = 0
defaultBillboard.AlwaysOnTop = true
local billboardText = Instance.new("TextLabel")
billboardText.Size = UDim2.new(1, 0, 1, 0)
billboardText.BackgroundTransparency = 1
billboardText.Text = ""
billboardText.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
billboardText.TextStrokeTransparency = 0
billboardText.Font = Enum.Font.Gotham
billboardText.TextScaled = true

local function makeBillboard(text, textcolor)
    local new = defaultBillboard:Clone()
    local newtext = billboardText:Clone()
    newtext.Text = text
    newtext.TextColor3 = textcolor
    newtext.Parent = new
    return new
end
function Service:GiveTitle(plr)
    local totalOresMined = self.Services.PlayerData:GetStore(plr, "TotalOresMined"):getState()

    local title = MinedBlocksTitleDictionary[1]
    for _, v in pairs(MinedBlocksTitleDictionary) do
        if v.OreCount > totalOresMined then
            break
        end
        title = v
    end

    local promise = GetPlayerCharacterWorkspace(plr):andThen(function(char)
        local _, primaryPart = GetPrimaryPart(char):awaitStatus()
        local head = char:FindFirstChild("Head")
        local newGui = makeBillboard(title.Name, title.TextColor3)
        newGui.Adornee = head
        newGui.Parent = primaryPart
    end)
end

return Service