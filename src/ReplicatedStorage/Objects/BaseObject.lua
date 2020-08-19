local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Enums = require(ReplicatedStorage.Enums)
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local DataDump = require(ReplicatedStorage.Utils.DataDump)

local BaseObject = {}
BaseObject.__index = BaseObject
BaseObject.ClassName = script.Name

function BaseObject.new(name)
    local self = setmetatable({}, BaseObject)
    self._maid = Maid.new()
    self.Enums = Enums
    self.TableUtil = TableUtil
    assert(name == nil or type(name) == "string", "Invalid name!")
    self.Name = name or ""
    self._debugLevel = 2
    self._destroyed = false
    return self
end

function BaseObject:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self._maid:Destroy()
end

function BaseObject:GetLogPrefix()
    if not self._logPrefix then
        self._logPrefix = string.format("[%s:%s]", self.ClassName, self.Name)
    end
    return self._logPrefix
end
function BaseObject:Log(lvl, ...)
    lvl = lvl or 0
    if self._debugLevel <= lvl then
        local args = {...} -- automatically unpack tables
        for key, val in ipairs(args) do
            if type(val) == "table" then
                args[key] = DataDump.dd(val)
            end
        end
        print(self:GetLogPrefix(), unpack(args))
    end
end

function BaseObject:SetLevel(level)
    assert(type(level) == "number", "Tried to set debugger to invalid level!")
    self._debugLevel = level
end

return BaseObject
