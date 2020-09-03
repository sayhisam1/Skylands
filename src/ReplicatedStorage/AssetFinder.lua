local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local ASSET_TEMP_DIR
if RunService:IsServer() or not RunService:IsRunning() then
    if not ServerStorage:FindFirstChild("TEMPORARY_ASSETS") then
        local dir = Instance.new("Folder")
        dir.Name = "TEMPORARY_ASSETS"
        dir.Parent = ServerStorage
    end
    ASSET_TEMP_DIR = ServerStorage:FindFirstChild("TEMPORARY_ASSETS")
else
    if not Lighting:FindFirstChild("TEMPORARY_ASSETS") then
        local dir = Instance.new("Folder")
        dir.Name = "TEMPORARY_ASSETS"
        dir.Parent = Lighting
    end
    ASSET_TEMP_DIR = Lighting:FindFirstChild("TEMPORARY_ASSETS")
end
ASSET_TEMP_DIR:ClearAllChildren()
local AssetFinder = {}

local ORES,
    PICKAXES,
    BACKPACKS,
    PETS,
    TITLES
if RunService:IsRunning() then
    ORES = ReplicatedStorage:WaitForChild("Ores")
    PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")
    PETS = ReplicatedStorage:WaitForChild("Pets")
    BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")
    TITLES = ReplicatedStorage:WaitForChild("Titles")
else
    ORES = Workspace:WaitForChild("Ores")
    PICKAXES = Workspace:WaitForChild("Pickaxes")
    PETS = Workspace:WaitForChild("Pets")
    BACKPACKS = Workspace:WaitForChild("Backpacks")
    TITLES = Workspace:WaitForChild("Titles")
end

function AssetFinder.FindOre(name)
    local asset = ORES:FindFirstChild(name, not RunService:IsRunning())
    if not asset then
        error("Couldn't find ore " .. name)
    end
    return asset
end

function AssetFinder.GetOres()
    return ORES
end

function AssetFinder.FindPickaxe(name)
    local asset = PICKAXES:FindFirstChild(name, not RunService:IsRunning())
    if not asset then
        error("Couldn't find pickaxe " .. name)
    end
    return asset
end

function AssetFinder.GetPickaxes()
    return PICKAXES
end

local PetBinder = require(ReplicatedStorage.Binders.PetBinder)
function AssetFinder.FindPet(name)
    local asset = PETS:FindFirstChild(name, not RunService:IsRunning())
    if not asset then
        error("Couldn't find pet " .. name)
    end
    asset = asset:Clone()
    asset.Parent = ASSET_TEMP_DIR
    if RunService:IsClient() or not RunService:IsRunning() then
        return PetBinder:BindClient(asset)
    end
    return PetBinder:Bind(asset)
end

function AssetFinder.GetPets()
    return PETS
end

function AssetFinder.FindBackpack(name)
    local asset = BACKPACKS:FindFirstChild(name, not RunService:IsRunning())
    if not asset then
        error("Couldn't find backpack " .. name)
    end
    return asset
end

function AssetFinder.GetBackpacks()
    return BACKPACKS
end

if RunService:IsRunning() then
    local SORTED_TITLES = TITLES:GetChildren()

    table.sort(
        SORTED_TITLES,
        function(a, b)
            return a.TotalOresMined.Value < b.TotalOresMined.Value
        end
    )

    function AssetFinder.GetTitleForCount(count)
        local currTitle = SORTED_TITLES[1]
        for _, v in pairs(SORTED_TITLES) do
            if v.TotalOresMined.Value > count then
                break
            end
            currTitle = v
        end
        return currTitle:FindFirstChildWhichIsA("BillboardGui")
    end
end

return AssetFinder
