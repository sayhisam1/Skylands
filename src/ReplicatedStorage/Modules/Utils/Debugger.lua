local Debugger = {LEVEL = 2}

setmetatable(
    Debugger,
    {
        __call = function(tbl, ...)
            return tbl:printd(...)
        end
    }
)
function Debugger:printd(lvl, ...)
    lvl = lvl or 0
    if (self.LEVEL <= lvl) then
        print("DEBUG:", ...)
    end
end
function Debugger:New()
    self.__index = self
    local obj = setmetatable({}, self)
    return obj
end
return Debugger
