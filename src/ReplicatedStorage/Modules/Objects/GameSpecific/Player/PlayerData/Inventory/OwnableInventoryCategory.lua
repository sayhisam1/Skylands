-- keeps track of owned assets
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local InventoryCategory = require("InventoryCategory")
local OwnableInventoryCategory = setmetatable({}, InventoryCategory)
OwnableInventoryCategory.__index = OwnableInventoryCategory
OwnableInventoryCategory.ClassName = script.Name

function OwnableInventoryCategory:New()
    self.__index = self
    local obj = setmetatable(InventoryCategory:New(),self)

    return obj
end

function OwnableInventoryCategory:New()
    self.__index = self
    local obj = setmetatable(InventoryCategory:New(),self)

    return obj
end

function OwnableInventoryCategory:DoesOwnItem(item_name)
    return self:GetAmountOf(item_name) > 0
end

function OwnableInventoryCategory:GiveItemOwnership(item_name)
    return self:SetAmountTo(item_name, 1)
end

function OwnableInventoryCategory:GiveItems(items)
    for item_name, value in pairs(items) do
        self:GiveItemOwnership(item_name)
    end
end
return OwnableInventoryCategory
