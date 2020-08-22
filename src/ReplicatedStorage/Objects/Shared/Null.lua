local tbl = {}

setmetatable(
    tbl,
    {
        __call = function()
            return tbl
        end,
        __newindex = function()
            return tbl
        end,
        __index = function()
            return tbl
        end
    }
)

return tbl
