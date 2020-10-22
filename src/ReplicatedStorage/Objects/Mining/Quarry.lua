local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ORES = ReplicatedStorage:WaitForChild("Ores")
local WALL_MATERIAL = ORES:WaitForChild("Bedrock")

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local SPAWNED_ORES = OreBinder:GetOresDirectory()

local Quarry = setmetatable({}, BaseObject)
local BLOCK_SIZE = 7

Quarry.__index = Quarry
Quarry.ClassName = script.Name

function Quarry.new(layer_probabilities, center_pos, length, width)
    local self = setmetatable(BaseObject.new(), Quarry)

    self._layerProbabilities = layer_probabilities
    self._length = length
    self._width = width
    self._centerPos = center_pos
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
    -- skip first two "expansions"
    local generator = self:_getLayerProbability(depth)
    local selected_ore = generator:Sample(1)[1]
    if depth < 5 then
        local CENTER_X = self._length / 2
        local CENTER_Z = self._width / 2
        if x <= CENTER_X - 5 or x > CENTER_X + 5 or z <= CENTER_Z - 5 or z > CENTER_Z + 5 then
            selected_ore = WALL_MATERIAL
        end
    elseif x < 1 or x > self._length or z < 1 or z > self._width then
        selected_ore = WALL_MATERIAL
    end

    new_instance = selected_ore:Clone()
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
    local depth_coord = self._centerPos - Vector3.new(0, depth * BLOCK_SIZE, 0)
    local ore_coordinate = depth_coord + Vector3.new(x - self._length / 2, 0, z - self._width / 2) * BLOCK_SIZE
    local block_center = ore_coordinate + Vector3.new(BLOCK_SIZE, BLOCK_SIZE, BLOCK_SIZE) * .5
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
