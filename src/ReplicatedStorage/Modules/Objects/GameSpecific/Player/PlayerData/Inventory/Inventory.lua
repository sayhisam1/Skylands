-- keeps track of owned assets
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local InventoryCategory = require("InventoryCategory")
local OwnableInventoryCategory = require("OwnableInventoryCategory")
local Inventory = {}
Inventory.__index = Inventory
Inventory.ClassName = script.Name

local categories = {"Ores", "Wood", "Axes", "Pickaxes"}
local DEFAULTS = {
    Pickaxes = {
        Primitive = 1
    },
    Axes = {
        Primitive = 1
    }
}
function Inventory:New()
    self.__index = self
    local obj = setmetatable({},self)

    
    obj.Ores = InventoryCategory:New()
    obj.Wood = InventoryCategory:New()
    obj.Pickaxes = OwnableInventoryCategory:New()
    obj.Axes = OwnableInventoryCategory:New()
    obj:GiveItems(DEFAULTS)
    return obj
end

function Inventory:GetOres()
    if not self.Ores then
        self.Ores = InventoryCategory:New()
    end 
    return self.Ores
end

function Inventory:GetWood()
    if not self.Wood then
        self.Wood = InventoryCategory:New()
    end 
    return self.Wood
end

function Inventory:GetAxes()
    if not self.Axes then
        self.Axes = InventoryCategory:New()
    end 
    return self.Axes
end

function Inventory:GetPickaxes()
    if not self.Pickaxes then
        self.Pickaxes = InventoryCategory:New()
    end 
    return self.Pickaxes
end

-- goes through all the categories and recursively calls :Validate on each category. Also ensures that metatables are correctly set (in the event that there is a change in classnames)
function Inventory:Validate()
    for _,category in pairs(categories) do
        if not self[category] then
            self[category] = InventoryCategory:New()
        end
        if not self[category].ClassName == InventoryCategory.ClassName then
            self[category].ClassName = InventoryCategory.ClassName
            setmetatable(self[category], InventoryCategory)
        end
        self[category]:Validate()
    end
end

function Inventory:GiveItems(items)
    for category, categoryItems in pairs(items) do
        if self[category] then
            self[category]:GiveItems(categoryItems)
        end
    end
end

return Inventory
