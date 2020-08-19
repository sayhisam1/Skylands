local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Enums = require(ReplicatedStorage.Enums)

local Octree = require(ReplicatedStorage.Lib.Octree)
local Binder = require(ReplicatedStorage.Objects.Shared.Binder)
local Ore = require(script.Ore)

local oreTree = Octree.new(Vector3.new(1E5, 1E7, 1E5) * -1, Vector3.new(1E5, 1E7, 1E5))

local OreBinder = Binder.new(Enums.Tags.Ore, Ore)

if RunService:IsServer() then
    local classAddedSignal = OreBinder:GetClassAddedSignal()
    classAddedSignal:Connect(
        function(ore)
            -- don't add original models to octree
            OreBinder:Log(1, "ADDED", ore:GetInstance())
            ore._maid:GiveTask(
                ore:GetInstance().PrimaryPart:GetPropertyChangedSignal("Position"):Connect(
                    function()
                        OreBinder:UpdateOrePos(ore)
                    end
                )
            )
            ore._maid:GiveTask(
                ore:GetInstance():GetPropertyChangedSignal("Parent"):Connect(
                    function()
                        OreBinder:UpdateOrePos(ore)
                    end
                )
            )
        end
    )

    local classRemovedSignal = OreBinder:GetClassRemovingSignal()
    classRemovedSignal:Connect(
        function(ore)
            if oreTree:Contains(ore) then
                oreTree:Remove(ore)
            end
        end
    )
    function OreBinder:GetNearestOreNeighbor(coords, max_dist)
        max_dist = max_dist or 3.5
        return oreTree:GetNearestNeighbor(coords, max_dist)
    end
end

function OreBinder:UpdateOrePos(ore)
    if oreTree:Contains(ore) then
        oreTree:Remove(ore)
    end
    if ore:GetInstance():IsDescendantOf(Workspace) then
        local pos = ore:GetCFrame().Position
        oreTree:Insert(pos, ore)
    end
end

function OreBinder:LookupInstance(instance)
    assert(instance, "Did not provide an instance!")
    if not instance:IsA("Model") then
        instance = instance:FindFirstAncestorWhichIsA("Model")
    end
    return self:Get(instance)
end

OreBinder:Init()

return OreBinder
