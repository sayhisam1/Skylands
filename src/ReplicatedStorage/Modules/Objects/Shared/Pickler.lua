---------------------------
--//  PICKLER OBJECT   \\--
--== Author: sayhisam1 ==--
---------------------------
-- IS STATIC
-- Implements a static pickler library that packages objects between client/server for usage in remote events/functions
-- #TODO: Add optional compression libraries to pickled data

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
local DataDump = require("DataDump")
local IGNORE_LIST = {
    -- Ignored keys for the pickler/unpickler
    __index = "__index",
    __newindex = "__newindex",
    __mode = "__mode",
    __call = "__call",
    __metatable = "__metatable",
    __tostring = "__tostring",
    __manager = "__manager",
    __eq = "__eq",
    __pickleable = "__pickleable",
    __strictMode = "__strictMode",
    __manager = "__manager",
    __pickleIgnore = "__pickleIgnore",
    __picklefunc = "__picklefunc",
    __unpicklefunc = "__unpicklefunc",
    __merge = "__merge",
    _maid = "_maid",
    _networkmaid = "_networkmaid",
    _channels = "_channels"
}

local ALWAYS_PICKLE = {
    -- list of keys to always pickle
    Id = "Id",
    ClassName = "ClassName",
}
local Pickler = {
    Ignored = IGNORE_LIST
}

-- helper functions --

-- inserts key from object into tbl
local function tbl_ins(obj, tbl, key)
    if IGNORE_LIST[key] or (obj.__pickleIgnore and obj.__pickleIgnore[key]) then
        return
    end
    assert(type(key) == "number" or type(key) == "string", "Unpickleable key! (given " .. type(key) .. "!)")
    local val = obj[key]

    if type(val) == "function" or type(val) == "nil" then
        return
    end
    local new_val = (type(obj.__picklefunc) == 'function' and obj:__picklefunc(key)) or Pickler:Pickle(obj[key])
    tbl[key] = new_val
end
local function tbl_unpickle(baseclass, tbl, key)
    if IGNORE_LIST[key] or (baseclass and baseclass.__pickleIgnore and baseclass.__pickleIgnore[key]) then
        return
    end
    local val = tbl[key]

    if type(val) == "function" or type(val) == "nil" then
        return
    end

    tbl[key] = (baseclass and type(baseclass.__unpicklefunc) == "function" and baseclass:__unpicklefunc(key, tbl[key])) or Pickler:Unpickle(tbl[key])
end

-- merges key from tbl into obj
local function tbl_merge(obj, tbl, key)
    if IGNORE_LIST[key] or (obj.__pickleIgnore and obj.__pickleIgnore[key]) then
        return
    end
    local val = tbl[key]

    if type(val) == "function" or type(val) == "nil" then
        return
    end

    obj[key] = (type(obj.__merge) == 'function' and obj:__merge(key, tbl[key])) or Pickler:Merge(obj[key], tbl[key])
end

--Pickles a given object
--@param object -- the object to pickle
--@param vararg keys -- If specified, only pickles the given keys (used to fine grain sent data)
function Pickler:Pickle(object, ...)
    local pickled = object
    if type(object) == "table" then
        pickled = {}
        local args = {...}
        if #args == 0 then
            for key, _ in pairs(object) do
                tbl_ins(object, pickled, key)
            end
        else
            for _, key in pairs(args) do
                tbl_ins(object, pickled, key)
            end
        end
        for key, _ in pairs(ALWAYS_PICKLE) do
            tbl_ins(object, pickled, key)
        end
    end
    return pickled
end

--Unpickles an object
-- NOTE: Valid objects MUST be defined in a specific way! The baseclass MUST have references to the baseclasses of the internal values! (this is so nested objects can correctly unpickle!)
function Pickler:Unpickle(pickled)
    if type(pickled) == 'table' then
        local baseclass = nil
        if type(pickled.ClassName) == 'string' then

            local stat, err = pcall(function()
                baseclass = require(pickled.ClassName)
            end)
            if not stat then
                warn(string.format("Failed to unpickle object with error:\n%s", tostring(err)))
                baseclass = {}
            end
            assert(type(baseclass) == "table", string.format("Invalid baseclass %s", tostring(pickled.ClassName)))
        end
        for key, _ in pairs(pickled) do
            tbl_unpickle(baseclass, pickled, key)
        end
        if baseclass then
            setmetatable(pickled, baseclass)
        end
    end
    return pickled
end

-- Merges the two objects
-- @param object - the object to merge into
-- @param to_merge - An unpickled instance of the same object
function Pickler:Merge(object, to_merge)
    if type(object) == 'table' and type(to_merge) == 'table' then
        for key, _ in pairs(to_merge) do
            if object.__strictMode and object[key] == nil then
                warn("INVALID KEY " .. key)
            else
                local old = object[key]
                tbl_merge(object, to_merge, key)
                if key == "ClassName" then -- tries to update classname to the base object's classname
                    object[key] = old or object[key]
                end
                if object._onMerge and object._onMerge[key] then
                    object._onMerge[key]:Fire(old, object[key])
                end
            end
        end
    else
        object = to_merge
    end
    return object
end

return Pickler
