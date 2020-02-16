-- Stores shared info between attack states

local AttackShared = {}
AttackShared.__index = AttackShared
function AttackShared:New()
    self.__index = self
    return setmetatable({}, self)
end

function AttackShared:Destroy()
end

return AttackShared
