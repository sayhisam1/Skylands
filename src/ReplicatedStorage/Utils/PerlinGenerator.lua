local mfloor = math.floor
local module = {}
module.__index = module
module.ClassName = script.Name

local function Permute(tbl, seed)
    if seed then
        math.randomseed(seed)
    end
    local len = #tbl
    for i = len, 1, -1 do
        local j = math.random(0, i)
        local tmp = tbl[i]
        tbl[i] = tbl[j]
        tbl[j] = tmp
    end
    return tbl
end
function module.new(seed, p_size)
    assert(type(seed) == "number", "Invalid seed!")
    p_size = p_size or 256
    local self = setmetatable({}, module)

    local P = {}
    for i = 0, p_size - 1, 1 do
        P[i] = i
    end
    Permute(P, seed)
    for i = 0, p_size - 1, 1 do
        P[i + p_size] = P[i]
    end

    self.P = P
    self._psize = p_size
    return self
end

local function lerp(t, a, b)
    return a + t * (b - a)
end
local function fade(t)
    return t * t * t * (t * (t * 6 - 15) + 10)
end
local function grad(h, x, y, z)
    h = h % 15
    local u, v
    if (h < 8) then
        u = x
    else
        u = y
    end

    if (h < 4) then
        v = y
    elseif (h == 12 or h == 14) then
        v = x
    else
        v = z
    end

    if (h % 2 == 1) then
        u = -1 * u
    end
    if (mfloor(h / 2) % 2 == 1) then
        v = -1 * v
    end
    return u + v
end

function module:noise(x, y, z)
    local X = mfloor(x) % self._psize
    local Y = mfloor(y) % self._psize
    local Z = mfloor(z) % self._psize
    local P = self.P
    x = x - mfloor(x)
    y = y - mfloor(y)
    z = z - mfloor(z)

    local u = fade(x)
    local v = fade(y)
    local w = fade(z)

    local A = P[X] + Y
    local AA = P[A] + Z
    local AB = P[A + 1] + Z
    local B = P[X + 1] + Y
    local BA = P[B] + Z
    local BB = P[B + 1] + Z

    --print(A,AA,AB,B,BA,BB)
    -- this thing is so messy >.<
    return lerp(
        w,
        lerp(
            v,
            lerp(u, grad(P[AA], x, y, z), grad(P[BA], x - 1, y, z)),
            lerp(u, grad(P[AB], x, y - 1, z), grad(P[BB], x - 1, y - 1, z))
        ),
        lerp(
            v,
            lerp(u, grad(P[AA + 1], x, y, z - 1), grad(P[BA + 1], x - 1, y, z - 1)),
            lerp(u, grad(P[AB + 1], x, y - 1, z - 1), grad(P[BB + 1], x - 1, y - 1, z - 1))
        )
    )
end

-- returns a list containing 4 object arrays, {x,y,z,noise}, for each point <x,y,z> in the range, where we have nchunk "blocks" on each axis
function module:noiseRange(sx, sy, sz, ex, ey, ez, step)
    local dx = (ex - sx)
    local dy = (ey - sy)
    local dz = (ez - sz)

    local list = {}
    for x = sx, ex, step do
        for y = sy, ey, step do
            for z = sz, ez, step do
                local x2 = x - sx
                local y2 = y - sy
                local z2 = z - sz
                list[#list + 1] = {x, y, z, self:frequencynoise(x2 / dx, y2 / dy, z2 / dz, 1, 1)}
            end
        end
    end
    return list
end
-- Compute noise over octave
function module:frequencynoise(x, y, z, octaves, persistence)
    persistence = persistence or 1
    local total = 0
    local ampl = 1
    local freq = 1
    local maxval = 0
    for i = 1, octaves, 1 do
        total = total + self:noise(x * freq, y * freq, z * freq) * ampl
        maxval = maxval + ampl
        ampl = ampl * persistence
        freq = freq * 2
    end
    return total / maxval
end
return module
