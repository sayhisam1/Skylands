-- keeps track of owned assets
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local InventoryCategory = {}
InventoryCategory.__index = InventoryCategory
InventoryCategory.ClassName = script.Name

function InventoryCategory:New()
    self.__index = self
    local obj = setmetatable({},self)

    obj._list = {}

    return obj
end

function InventoryCategory:GetAmountOf(object_name)
    return self._list[object_name] or 0
end

function InventoryCategory:SetAmountTo(object_name, amount)
    self._list[object_name] = amount
    if amount == 0 then
        self._list[object_name] = nil
    end
    return amount
end

function InventoryCategory:ChangeAmountBy(object_name, amount)
    return self:SetAmountTo(object_name, self:GetAmountOf(object_name) + amount)
end

function InventoryCategory:GiveItems(items)
    for item_name, amount in pairs(items) do
        self:ChangeAmountBy(item_name, amount)
    end
end

function InventoryCategory:SetItems(items)
    for item_name, amount in pairs(items) do
        self:SetAmountTo(item_name, amount)
    end
end

function InventoryCategory:GetItems()
    return self._list
end

function InventoryCategory:Validate()
    --not implemented--
end
return InventoryCategory
