--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------
local ASSET_DIR = ReplicatedStorage:WaitForChild("Assets")
local GAME_ASSETS = ASSET_DIR:WaitForChild("Game")
local GAME_ASSET_CATEGORIES = {"Ores", "Wood", "Pickaxes", "Axes"}
local ID_TBL_NAME = "IdTable"

local Maid = require("Maid").new()

local category_tbl = {}
function Service:Load()
    for _, v in pairs(GAME_ASSET_CATEGORIES) do
        local category = GAME_ASSETS:WaitForChild(v)
        local id_tbl = category:WaitForChild(ID_TBL_NAME)
        category_tbl[v] = require(id_tbl)
    end
end

function Service:Unload()
    category_tbl = {}
    Maid:Destroy()
end

function Service:FindCategoryFolder(category)
    local category = GAME_ASSETS:FindFirstChild(category)
    if not category then
        error(string.format("Tried to find invalid category %s", category))
    end
    return category
end

-- Returns a clone of the asset found with category and id
-- @param category  -   The category to lookup (see GAME_ASSET_CATEGORIES for a valid list)
-- @param id        -   The id of the object (should be a string!)
function Service:GetAsset(category, id)
    assert(
        type(category) == "string" and category_tbl[category],
        string.format("Invalid category %s of type %s provided!", tostring(category), tostring(type(category)))
    )
    assert(
        type(id) == "string" and category_tbl[category][id],
        string.format("Invalid id %s of type %s provided!", tostring(id), tostring(type(id)))
    )
    local asset = category_tbl[category][id]:Clone()
    return asset
end

-- Returns the configuration value for a given asset
function Service:GetAssetConfigurationValue(category, id, config_name)
    local asset = self:GetAsset(category, id)
    local configuration_folder = asset:FindFirstChildWhichIsA("Configuration")
    if not configuration then
        return nil
    end
    local value = configuration_folder:FindFirstChild(config_name)
    if not value then
        return nil
    end
    if value:IsA("ModuleScript") then
        return require(value)
    end
    if value:IsA("ValueBase") then
        return value.Value
    end
end
-- Returns a viewport version of the asset
function Service:GetAssetViewport(category, id)
    assert(
        type(category) == "string" and category_tbl[category],
        string.format("Invalid category %s of type %s provided!", tostring(category), tostring(type(category)))
    )
    assert(
        type(id) == "string" and category_tbl[category][id],
        string.format("Invalid id %s of type %s provided!", tostring(id), tostring(type(id)))
    )
    local asset = category_tbl[category][id]:Clone()
    return asset
end

function Service:GetAssetFolder()
    return ASSET_DIR
end

return Service
