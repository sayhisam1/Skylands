local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ORES = ReplicatedStorage:WaitForChild("Ores")
local WALL_MATERIAL = ORES:WaitForChild("Bedrock")

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local OreBinder = require(ReplicatedStorage.OreBinder)
local SPAWNED_ORES = OreBinder:GetOresDirectory()

local Quarry = setmetatable({}, BaseObject)
local BLOCK_SIZE = 7

Quarry.__index = Quarry
Quarry.ClassName = script.Name

function Quarry.new(layer_probabilities, bottom_left_pos, length, width)
    local self = setmetatable(BaseObject.new(), Quarry)

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

    local pos = self:GetAbsoluteCoordinates(depth, x, z)
    new_instance:SetPrimaryPartCFrame(CFrame.new(pos))
    new_instance.Parent = SPAWNED_ORES
    local ore = OreBinder:Bind(new_instance)
    self._maid:GiveTask(ore)

    ore._quarry = self -- HACK: inject quarry ref into ore

    self:MarkHasSpawned(ore, depth, x, z)

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
        self._spawnedCoords[depth] = table.create(self._length + 1)
    end
    if not self._spawnedCoords[depth][x] then
        self._spawnedCoords[depth][x] = table.create(self._width + 1)
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

return Quarry
