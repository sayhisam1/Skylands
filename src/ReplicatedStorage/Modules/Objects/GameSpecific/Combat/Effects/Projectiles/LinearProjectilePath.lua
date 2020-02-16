local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))


local LinearProjectilePath = {}
LinearProjectilePath.__index = LinearProjectilePath
LinearProjectilePath.Name = script.Name

function LinearProjectilePath:New(origin, direction, speed)
    self.__index = self
    local obj = setmetatable({},self)
    obj._origin = origin
    obj._direction = direction
    obj._speed = speed
    return obj
end

function LinearProjectilePath:GetCFrameAtTime(time)
    return origin + direction*time*speed
end

return LinearProjectilePath