local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)

local ViewportContainer = Roact.Component:extend("ViewportContainer")

local function setInstanceCFrame(instance, cframe)
    local parts = {}
    local midpointPosition = Vector3.new(0, 0, 0)
    for _,v in pairs(instance:GetDescendants()) do
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
    local midpointCFrame = midpointPart.CFrame
    local relativeCFrames = {}
    for _, part in pairs(parts) do
        relativeCFrames[part] = midpointCFrame:ToObjectSpace(part.CFrame)
    end
    midpointPart.CFrame = cframe
    for part, object_cframe in pairs(relativeCFrames) do
        part.CFrame = midpointPart.CFrame:ToWorldSpace(object_cframe)
    end
end

function ViewportContainer:init()
    self.viewportRef = Roact.createRef()
end

function ViewportContainer:render()
    return Roact.createElement("ViewportFrame", {
        BackgroundTransparency = self.props.BackgroundTransparency or 1,
        Size = self.props.Size,
        Position = self.props.Position,
        AnchorPoint = self.props.AnchorPoint or Vector2.new(0, 0),
        BackgroundColor3 = self.props.BackgroundColor3 or Color3.fromRGB(0, 0, 0),
        BorderSizePixel = self.props.BorderSizePixel or 0,
        [Roact.Ref] = self.viewportRef
    }, self.props[Roact.Children])
end

function ViewportContainer:didUpdate()
    local ref = self.viewportRef:getValue()
    for _, v in pairs(ref:GetChildren()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            v:Destroy()
        end
    end
    local renderedModel = self.props.RenderedModel:Clone()
    local modelCFrame = self.props.ModelCFrame or CFrame.new(0, 0, 0)
    if renderedModel:IsA("Tool") then
        if renderedModel:FindFirstChild("Parts") then
            renderedModel = renderedModel:FindFirstChild("Parts")
        end
    end
    if renderedModel:IsA("Model") and renderedModel.PrimaryPart then
        renderedModel:SetPrimaryPartCFrame(modelCFrame)
    elseif renderedModel:IsA("BasePart") then
        renderedModel.CFrame = modelCFrame
    else
        print("FORCED TO INFER PRIMARY PART FOR", renderedModel:GetFullName())
        setInstanceCFrame(renderedModel, modelCFrame)
    end
    local camera = Instance.new("Camera")
    camera.CFrame = self.props.CameraCFrame or CFrame.new(0, 0, 1)
    camera.CFrame = CFrame.new(camera.CFrame.Position, modelCFrame.Position)
    ref.CurrentCamera = camera
    renderedModel.Parent = ref
end

return ViewportContainer
