local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local spr = require(ReplicatedStorage.Lib.spr)
local LAYER_LIGHTING = script.LayerLighting:GetChildren()
LAYER_LIGHTING = Service.TableUtil.map(LAYER_LIGHTING, function(_, v)
    local layer_num = tonumber(string.gmatch(v.Name, "%d+")())
    return {
        Depth = layer_num,
        Generator = require(v)
    }
end)
table.sort(LAYER_LIGHTING, function(a, b)
    return a.Depth < b.Depth
end)

local function getLayerLighting(depth)
    local selected_layer
    for _, preset in ipairs(LAYER_LIGHTING) do
        if depth < preset.Depth then
            break
        end
        selected_layer = preset.Generator
    end

    return selected_layer
end

local currLighting = nil
function Service:Load()
    local charAdded = function(char)
        local event = RunService.Heartbeat:Connect(function()
            if not char.PrimaryPart then
                return
            end
            local depth = math.max(math.ceil((char.PrimaryPart.Position.Y - 50000)/7 * -1), 0)
            local lighting = getLayerLighting(depth)
            if lighting and lighting ~= currLighting then
                currLighting = lighting
                for category, values in pairs(lighting) do
                    spr.target(category, 1, 1, values)
                end
            end
        end)
        self._maid["character"] = event
    end
    Players.LocalPlayer.CharacterAdded:Connect(charAdded)
    if game.Players.LocalPlayer.Character then
        charAdded(game.Players.LocalPlayer.Character)
    end
end

return Service