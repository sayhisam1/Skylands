local PlayerDataCategory = {}

--CONSTRUCTOR--
PlayerDataCategory.__index = PlayerDataCategory
--Strict Mode dictates that new indices cannot be added after creation (prevents unserializing new values)--
PlayerDataCategory.__strictMode = true
function PlayerDataCategory:New()
    self.__index = self
    local obj = setmetatable({}, self)
    for i, v in pairs(self) do
        if type(v) == "table" and v ~= self then
            obj[i] = v:New()
        elseif type(v) ~= "function" and type(v) ~= "table" and i ~= "__strictMode" then
            obj[i] = v
        end
    end
    return obj
end

--=GETTERS=--

--=UTILITIES=--

--SETTERS--

function PlayerDataCategory:__picklefunc(key)
    return self[key]
end

-- Updates this player object with values from pickled data
function PlayerDataCategory:__merge(key, val)
    return val
end
function PlayerDataCategory:__unpicklefunc(key, val)
    return val
end

return PlayerDataCategory
