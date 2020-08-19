local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetFinder = {}

local ORES = ReplicatedStorage:WaitForChild("Ores")
function AssetFinder.FindOre(name)
    local asset = ORES:FindFirstChild(name)
    if not asset then
        error("Couldn't find ore "..name)
    end
    return asset
end

function AssetFinder.GetOres()
    return ORES
end

local PICKAXES = ReplicatedStorage:WaitForChild("Pickaxes")
function AssetFinder.FindPickaxe(name)
    local asset = PICKAXES:FindFirstChild(name)
    if not asset then
        error("Couldn't find pickaxe "..name)
    end
    return asset
end

function AssetFinder.GetPickaxes()
    return PICKAXES
end

local PETS = ReplicatedStorage:WaitForChild("Pets")
function AssetFinder.FindPet(name)
    local asset = PETS:FindFirstChild(name)
    if not asset then
        error("Couldn't find pet "..name)
    end
    return asset
end

function AssetFinder.GetPets()
    return PETS
end

local BACKPACKS = ReplicatedStorage:WaitForChild("Backpacks")
function AssetFinder.FindBackpack(name)
    local asset = BACKPACKS:FindFirstChild(name)
    if not asset then
        error("Couldn't find backpack "..name)
    end
    return asset
end

function AssetFinder.GetBackpacks()
    return BACKPACKS
end

return AssetFinder