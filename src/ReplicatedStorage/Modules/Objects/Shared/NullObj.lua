-- Null obj class
-- Basically, it just takes in everything and makes it not error on index or call

local NullObj = {}
setmetatable(
    NullObj,
    {
        __index = function()
            return NullObj
        end,
        __call = function()
        end
    }
)

return NullObj
