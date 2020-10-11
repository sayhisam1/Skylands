local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)

local DEPENDENCIES = {"EffectsService"}
Service:AddDependencies(DEPENDENCIES)

local Quarry = require(ReplicatedStorage.Objects.Mining.Quarry)
local QUARRY_CENTER = Vector3.new(35, 50003.5, 35)
local QUARRY_LENGTH = 100
local QUARRY_WIDTH = 100

local QUARRY_RESPAWN_TIMER = 45 * 60
local LAYER_PRESETS = {}

for _, v in pairs(game.ServerScriptService.QuarryLayers:GetChildren()) do
    local layer_num = tonumber(string.gmatch(v.Name, "%d+")())
    table.insert(LAYER_PRESETS, {Depth = layer_num, Generator = require(v)})
end

table.sort(
    LAYER_PRESETS,
    function(a, b)
        assert(a.Depth ~= b.Depth or a == b, "Duplicate depth "..a.Depth)
        return a.Depth < b.Depth
    end
)

function Service:Load()
    local currId = self:GetLoadId()
    coroutine.wrap(
        function()
            while self:GetLoadId() == currId do
                local stat, err
                while not stat do
                    stat, err = pcall(function()
                        self:ReloadQuarry()
                    end)
                end
                wait(QUARRY_RESPAWN_TIMER)
            end
        end
    )()
end

function Service:Unload()
    self._maid:Destroy()
end

local pocket_dimension = nil
function Service:GetPocketDimension()
    return pocket_dimension
end

function Service:SetPocketDimension(dimension)
    pocket_dimension = dimension
end

local quarry
function Service:ReloadQuarry()
    self:Log(3, "Loading quarry!")
    self._maid:Destroy()
    for _, v in pairs(game.Players:GetChildren()) do
        local stat, erro = pcall(function()
            v:LoadCharacter()
        end)
        if not stat then
            self:Log(3, erro)
        end
    end
    quarry = Quarry.new(LAYER_PRESETS, QUARRY_CENTER, QUARRY_LENGTH, QUARRY_WIDTH)
    self._maid:GiveTask(quarry)
    local MID_X = QUARRY_LENGTH/2
    local MID_Z = QUARRY_WIDTH/2
    for i = MID_X-5, MID_X+5 do
        for j = MID_Z-5, MID_Z+5 do
            quarry:GenerateOre(1, i, j)
            RunService.Heartbeat:Wait()
        end
    end
end

function Service:GetQuarry()
    return quarry
end

return Service
