local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)

local DEPENDENCIES = {"EffectsService"}
Service:AddDependencies(DEPENDENCIES)

local Ores = ReplicatedStorage:WaitForChild("Ores")

local Quarry = require(ReplicatedStorage.Objects.Mining.Quarry)
local QUARRY_BOTTOM_LEFT_POS = Vector3.new(0, 3.5, 0)
local QUARRY_LENGTH = 10
local QUARRY_WIDTH = 10

local QUARRY_RESPAWN_TIMER = 45 * 60
local LAYER_PRESETS = {}

for _, v in pairs(game.ServerScriptService.QuarryLayers:GetChildren()) do
    local layer_num = tonumber(string.gmatch(v.Name, "%d+")())
    table.insert(LAYER_PRESETS, {Depth = layer_num, Generator = require(v)})
end

table.sort(
    LAYER_PRESETS,
    function(a, b)
        return a.Depth < b.Depth
    end
)

function Service:Load()
    local maid = self._maid
    local currId = self:GetLoadId()
    coroutine.wrap(function()
        while self:GetLoadId() == currId do
            self:ReloadQuarry()
            wait(QUARRY_RESPAWN_TIMER)
        end
    end)()
end

function Service:Unload()
    self._maid:Destroy()
end

local quarry
function Service:ReloadQuarry()
    self:Log(2, "Loading quarry!")
    self._maid:Destroy()
    for _, v in pairs(game.Players:GetChildren()) do
        v:LoadCharacter()
    end
    quarry = Quarry.new(LAYER_PRESETS, QUARRY_BOTTOM_LEFT_POS, QUARRY_LENGTH, QUARRY_WIDTH)
    self._maid:GiveTask(quarry)
    for i = 1, QUARRY_LENGTH do
        for j = 1, QUARRY_WIDTH do
            quarry:GenerateOre(1, i, j)
        end
    end
end

function Service:GetQuarry()
    return quarry
end

return Service
