local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local Maid = require("Maid")
local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)

local AttackDetector = {}
AttackDetector.__index = AttackDetector

--CONSTRUCTOR--

-- creates a new detector with specified focus
-- @param focus -- a "focus" for the detector (can be like a vector3, a cframe, a part, etc... - basically whatever is expected by the inherited detector)
function AttackDetector:New(focus)
    self.__index = self
    local obj = setmetatable({}, self)
    obj._maid = Maid.new()
    obj._maid:GiveTask(obj.HitPlayer)
    obj._maid:GiveTask(obj.HitPart)
    obj._focus = focus
    return obj
end
function AttackDetector:Disconnect()
    self._maid:Destroy()
end
function AttackDetector:Destroy()
    self:Disconnect()
end
function AttackDetector:Connect()
    warn("CALLED ATTACK DETECTOR SUPER! (error?)")
end

return AttackDetector
