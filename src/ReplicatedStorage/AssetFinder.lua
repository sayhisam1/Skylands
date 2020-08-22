local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local AssetFinder = {}

local ORES,
    PICKAXES,
    BACKPACKS,
    PETS
if RunService:IsRunning() then
    ORES = ReplicatedStorage:WaitForChild("Ores")
    PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")
    PETS = ReplicatedStorage:WaitForChild("Pets")
    BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")
else
    ORES = Workspace:WaitForChild("Ores")
    PICKAXES = Workspace:WaitForChild("Pickaxes")
    PETS = Workspace:WaitForChild("Pets")
    BACKPACKS = Workspace:WaitForChild("Backpacks")
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

function AssetFinder.FindPet(name)
    local asset = PETS:FindFirstChild(name, not RunService:IsRunning())
    if not asset then
        error("Couldn't find pet " .. name)
    end
    return asset
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

return AssetFinder
