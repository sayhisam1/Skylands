local tbl

tbl = {
    __call = function()
        return tbl
    end,
    __newindex = function()
        return tbl
    end,
    __index = function(t, i)
        local val = rawget(t, i)
        return val or tbl
    end
}
setmetatable(tbl, tbl)

return tbl
