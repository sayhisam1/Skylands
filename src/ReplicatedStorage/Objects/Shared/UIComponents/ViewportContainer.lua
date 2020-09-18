local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Roact = require(ReplicatedStorage.Lib.Roact)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local ViewportContainer = Roact.Component:extend("ViewportContainer")

local function setInstanceCFrame(instance, cframe)
    local parts = {}
    local midpointPosition = Vector3.new(0, 0, 0)
    for _, v in pairs(instance:GetDescendants()) do
        if v:IsA("BasePart") then
            table.insert(parts, v)
            midpointPosition = midpointPosition + v.Position
        end
    end
    if #parts == 0 then
        return
    end
    midpointPosition = midpointPosition / #parts
    local midpointPart,
        dist = nil, math.huge
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

ViewportContainer.defaultProps = {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(.5, 0, .5, 0),
    AnchorPoint = Vector2.new(.5, .5),
    ShadowOffset = UDim2.new(.1, 0, .1, 0),
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BorderSizePixel = 0,
}

function ViewportContainer:init()
    self.viewportRef = Roact.createRef()
    self:setState(
        {
            maid = Maid.new()
        }
    )
end

function ViewportContainer:render()
    return Roact.createElement(
        "ViewportFrame",
        {
            BackgroundTransparency = self.props.BackgroundTransparency,
            Size = self.props.Size,
            Position = self.props.Position,
            AnchorPoint = self.props.AnchorPoint,
            BackgroundColor3 = self.props.BackgroundColor3,
            BorderSizePixel = self.props.BorderSizePixel,
            [Roact.Ref] = self.viewportRef
        },
        self.props[Roact.Children]
    )
end

local function viewportUpdate(self)
    self.state.maid:Destroy()
    local ref = self.viewportRef:getValue()
    if not ref then
        return
    end
    for _, v in pairs(ref:GetChildren()) do
        if v:IsA("Model") or v:IsA("BasePart") then
            v:Destroy()
        end
    end
    local renderedModel = self.props.RenderedModel
    if not renderedModel then
        return
    end
    renderedModel = renderedModel:Clone()
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
    self.renderedModel = renderedModel
    self.state.maid:GiveTask(camera)
    self.state.maid:GiveTask(renderedModel)
end

function ViewportContainer:didMount()
    viewportUpdate(self)
    self.running = true
    local i = 0
    coroutine.wrap(function()
        while self.running and i%3 == 0 do
            i=0
            print("UPDATE")
            if self.renderedModel then
                local old_cf = self.renderedModel.PrimaryPart.CFrame
                self.renderedModel:SetPrimaryPartCFrame(old_cf * CFrame.Angles(0, math.pi/100, 0))
            end
            RunService.Heartbeat:Wait()
        end
        i = i + 1
    end)()
end

function ViewportContainer:didUpdate()
    viewportUpdate(self)
end

function ViewportContainer:willUnmount()
    self.running = false
    self.renderedModel = nil
    self.state.maid:Destroy()
end

return ViewportContainer
