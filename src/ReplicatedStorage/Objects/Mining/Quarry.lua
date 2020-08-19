local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ORES_DIR = ReplicatedStorage:WaitForChild("Ores")
local WALL_MATERIAL = ORES_DIR:WaitForChild("Bedrock")

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local OreBinder = require(ReplicatedStorage.OreBinder)

local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local Quarry = setmetatable({}, BaseObject)
local BLOCK_SIZE = 7

Quarry.__index = Quarry
Quarry.ClassName = script.Name

function Quarry.new(layer_probabilities, bottom_left_pos, length, width)
    local self = setmetatable(BaseObject.new(), Quarry)

    self._tag = HttpService:GenerateGUID(false)
    self._layerProbabilities = layer_probabilities
    self._length = length
    self._width = width
    self._bottomLeftPos = bottom_left_pos
    self._spawnedCoords = {} -- Mark ores as spawned to prevent duplicate spawning

    return self
end

function Quarry:GetLength()
    return self._length
end

function Quarry:GetWidth()
    return self._width
end

function Quarry:_getLayerProbability(depth)
    assert(depth >= 1, "Invalid depth!")
    local selected_layer
    for _, preset in ipairs(self._layerProbabilities) do
        if depth < preset.Depth then
            break
        end
        selected_layer = preset.Generator
    end

    return selected_layer
end

function Quarry:GenerateOre(depth, x, z)
    if depth < 1 then
        return
    end
    if self:CheckIfHasSpawned(depth, x, z) then
        return
    end
    -- spawn wall of quarry
    local new_instance
    if x < 1 or x > self._length or z < 1 or z > self._width then
        if depth <= 1 then
            return
        end
        new_instance = WALL_MATERIAL:Clone()
    else
        local generator = self:_getLayerProbability(depth)
        local selected_ore = generator:Sample(1)[1]
        new_instance = selected_ore:Clone()
    end
    self._maid[new_instance] = new_instance

    self:Log(1, "Spawning ore", new_instance, "at", depth, x, z)

    new_instance.Parent = Workspace
    local ore = OreBinder:Bind(new_instance)
    CollectionService:AddTag(new_instance, self._tag)

    ore:SetAttribute("QuarryTag", self._tag)
    ore._quarry = self -- HACK: inject quarry ref into ore

    ore:SetAttribute("TableRef", tostring(ore))
    local pos = self:GetAbsoluteCoordinates(depth, x, z)
    ore:SetCFrame(CFrame.new(pos))

    self:MarkHasSpawned(ore, depth, x, z)
    ore:SetAttribute("Depth", depth)
    ore:SetAttribute("X", x)
    ore:SetAttribute("Z", z)

    ore._maid:GiveTask(
        function()
            if self._destroyed then
                return
            end
            self._spawnedCoords[depth][x][z] = true -- clear instance from spawned ores list
            local neighboringCoords = self:GetNeighboringCoordinates(depth, x, z)
            for _, v in pairs(neighboringCoords) do
                self:GenerateOre(unpack(v))
            end
        end
    )

    ore._maid:GiveTask(function()
        self._maid[new_instance] = nil
    end)
    -- handle transparent blocks (Spawn neighboring blocks)
    if ore:GetAttribute("Translucent") then
        local neighboringCoords = self:GetNeighboringCoordinates(depth, x, z)
        for _, v in pairs(neighboringCoords) do
            self:GenerateOre(unpack(v))
        end
    end

    return ore
end

function Quarry:CheckIfHasSpawned(depth, x, z)
    return self._spawnedCoords[depth] and self._spawnedCoords[depth][x] and self._spawnedCoords[depth][x][z]
end

function Quarry:MarkHasSpawned(ore, depth, x, z)
    if not self._spawnedCoords[depth] then
        self._spawnedCoords[depth] = {}
    end
    if not self._spawnedCoords[depth][x] then
        self._spawnedCoords[depth][x] = {}
    end
    self._spawnedCoords[depth][x][z] = ore
end

function Quarry:GetAbsoluteCoordinates(depth, x, z)
    -- HACK: need to offset coordinates by 1 since lua is stupid
    x = x - 1
    z = z - 1
    local layer_corner = self._bottomLeftPos - Vector3.new(0, depth * BLOCK_SIZE, 0)
    local curr_bottom_left = layer_corner + Vector3.new(x, 0, z) * BLOCK_SIZE
    local block_center = curr_bottom_left + Vector3.new(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE) * .5
    return block_center
end

function Quarry:GetRelativeCoordinates(x, y, z)
    local offset = Vector3.new(x, y, z) - self._bottomLeftPos
    local relative = offset / BLOCK_SIZE
    local depth = math.ceil(-1 * relative.Y)
    local x = math.ceil(relative.X)
    local z = math.ceil(relative.Z)

    return depth, x, z
end

function Quarry:GetBlockAtRelativeCoordinates(depth, x, z)
    if self._spawnedCoords[depth] and self._spawnedCoords[depth][x] and self._spawnedCoords[depth][x][z] then
        local marked = self._spawnedCoords[depth][x][z]
        if marked == true then
            marked = nil
        end
        return marked
    end
end

function Quarry:GetBlockAtAbsoluteCoordinates(x, y, z)
    local depth, x, z = self:GetRelativeCoordinates(x, y, z)
    return self:GetBlockAtRelativeCoordinates(depth, x, z)
end

function Quarry:GetNeighboringCoordinates(depth, x, z)
    return {
        {depth + 1, x, z},
        {depth - 1, x, z},
        {depth, x - 1, z},
        {depth, x + 1, z},
        {depth, x, z - 1},
        {depth, x, z + 1}
    }
end

function Quarry:GetCubeCoordinatesCenteredAt(size, depth, x, z)
    local list = table.create((2 * size + 1) ^ 3 - 1, 0)
    local idx = 1
    for dY = depth - size, depth + size, 1 do
        for dX = x - size, x + size, 1 do
            for dZ = z - size, z + size, 1 do
                if dY ~= depth or dX ~= x or dZ ~= z then
                    list[idx] = {dY, dX, dZ}
                    idx = idx + 1
                end
            end
        end
    end
    return list
end

function Quarry:Destroy()
    self._destroyed = true
    self._maid:Destroy()
end

return Quarry
