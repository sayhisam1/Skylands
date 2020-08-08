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
    model.PrimaryPart = midpointPart
end

function module.WeldTogether(model)
    assert(model:IsA("Model") and model.PrimaryPart, "Need to pass a model with primary part!")
    for _,v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") and v ~= model.PrimaryPart then
            local wc = Instance.new("WeldConstraint")
            wc.Part0 = model.PrimaryPart
            wc.Part1 = v
            wc.Name = v.Name
            wc.Parent = model.PrimaryPart
        end
    end
end

return module