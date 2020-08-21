local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Welding = require(ReplicatedStorage.Utils.Welding)
local module = {}

function module.AutosetPrimaryPart(model)
    assert(model:IsA("Model"), "Need to pass a model!")

    local parts = {}
    local midpointPosition = Vector3.new(0, 0, 0)
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(parts, v)
            midpointPosition = midpointPosition + v.Position
        end
    end
    if #parts == 0 then
        return
    end
    midpointPosition = midpointPosition / #parts
    local midpointPart, dist = nil, math.huge
    for _, part in pairs(parts) do
        local currDist = (part.Position - midpointPosition).Magnitude
        if currDist < dist then
            dist = currDist
            midpointPart = part
        end
    end
    return midpointPart
end

function module.WeldTogether(model)
    assert(model:IsA("Model") and model.PrimaryPart, "Need to pass a model with primary part!")
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v ~= model.PrimaryPart then
            Welding.weldTogether(model.PrimaryPart, v)
        end
    end
end

function module.SetAnchored(model, anchored)
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = anchored
        end
    end
end

function module.SetCanCollide(model, cancollide)
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = cancollide
        end
    end
end
return module