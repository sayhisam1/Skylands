local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Entity = {}
Entity.__index = Entity
function Entity:New(id)
    self.__index = self

    assert(type(id) == "number" or type(id) == "string", "Invalid id!")
    local obj = setmetatable({}, self)
    obj.Id = tostring(id) -- we ALWAYS need STRING ids - get this weak number shit outta here
    return obj
end

function Entity:GetId()
    return tostring(self.Id)
end
return Entity
