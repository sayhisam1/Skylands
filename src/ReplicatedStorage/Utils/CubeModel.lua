local FACE_COLORS = {
    [Enum.NormalId.Back] = Color3.fromRGB(255, 139, 116),
    [Enum.NormalId.Front] = Color3.fromRGB(255, 0, 0),
    [Enum.NormalId.Left] = Color3.fromRGB(0, 255, 0),
    [Enum.NormalId.Right] = Color3.fromRGB(0, 0, 255),
    [Enum.NormalId.Top] = Color3.fromRGB(251, 255, 0),
    [Enum.NormalId.Bottom] = Color3.fromRGB(255, 255, 255)
}

local X_FACES = {
    [-1] = Enum.NormalId.Left,
    [1] = Enum.NormalId.Right
}
local Y_FACES = {
    [-1] = Enum.NormalId.Bottom,
    [1] = Enum.NormalId.Top
}
local Z_FACES = {
    [-1] = Enum.NormalId.Front,
    [1] = Enum.NormalId.Back
}

local function makeTexture(face)
    local texture = Instance.new("Decal")
    texture.Face = face
    texture.Color3 = FACE_COLORS[face]
    texture.Texture = "rbxassetid://5553775674"
    return texture
end

local function round(num)
    local up = math.ceil(num)
    local down = math.floor(num)
    if math.abs(up - num) < math.abs(down - num) then
        return up
    end
    return down
end

local module = {}
module.__index = module
module.ClassName = script.Name

function module.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Cube!")

    local self = setmetatable({}, module)

    self._rotating = false
    self._instance = instance

    return self
end

function module:getCube(pos)
    for _, v in pairs(self._instance:GetChildren()) do
        if v:IsA("BasePart") and v:FindFirstChild("Position") and v:FindFirstChild("Position").Value == pos then
            return v
        end
    end
end

local FACES = {
    Enum.NormalId.Back,
    Enum.NormalId.Front,
    Enum.NormalId.Top,
    Enum.NormalId.Bottom,
    Enum.NormalId.Left,
    Enum.NormalId.Right
}

local DIRECTIONS = {
    "clockwise",
    "counter-clockwise"
}
function module:scramble(n)
    n = n or 1
    for i = 1, n do
        self:rotateFace(FACES[math.random(1, #FACES)], DIRECTIONS[math.random(1, #DIRECTIONS)])
    end
end

function module:rotateFace(face, direction)
    if self._rotating then
        return
    end
    self._rotating = true
    local rotvec
    if direction == "clockwise" then
        rotvec = Vector3.new(-1, -1, -1) * math.pi / 2
    else
        rotvec = Vector3.new(1, 1, 1) * math.pi / 2
    end
    local center_pos = Vector3.FromNormalId(face)
    local center_cube = self:getCube(center_pos)
    local cubes = {}
    local cube_cframes = {}
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            for z = -1, 1, 1 do
                local pos = Vector3.new(x, y, z)
                if pos:Dot(center_pos) == 1 then
                    local currcube = self:getCube(pos)
                    cubes[#cubes + 1] = currcube
                    cube_cframes[#cube_cframes + 1] = currcube.CFrame
                end
            end
        end
    end

    local center_cf = center_cube.CFrame
    local local_cf = {center_cf:ToObjectSpace(unpack(cube_cframes))}
    local angle_vec = rotvec * center_pos

    for lerp = 0, 1, .1 do
        local rotation_frame = CFrame.Angles(angle_vec.X * lerp, angle_vec.Y * lerp, angle_vec.Z * lerp)
        local rotated_center = center_cf * rotation_frame
        local target_cf = {rotated_center:ToWorldSpace(unpack(local_cf))}
        workspace:BulkMoveTo(cubes, target_cf)
        wait()
    end

    local rotation_frame = CFrame.Angles(angle_vec.X, angle_vec.Y, angle_vec.Z)
    for i, v in ipairs(cubes) do
        if v ~= center_cube then
            local pos = v:FindFirstChild("Position")
            if not pos then
                return
            end
            pos = pos.Value
            local rotated_pos = rotation_frame * pos
            local new_pos = Vector3.new(round(rotated_pos.X), round(rotated_pos.Y), round(rotated_pos.Z))
            v:FindFirstChild("Position").Value = new_pos
        end
    end
    self._rotating = false
end

function module:CreateCube(root, cube)
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            for z = -1, 1, 1 do
                local shift = Vector3.new(x, y, z) * root.Size.X / 3
                local clone = cube:Clone()
                clone.CFrame = root.CFrame + shift
                clone.Parent = self._instance

                local pos = Instance.new("Vector3Value")
                pos.Value = Vector3.new(x, y, z)
                pos.Name = "Position"
                pos.Parent = clone
                clone.Name = "cube"
                clone.Color = Color3.new(0, 0, 0)
                clone.Transparency = 0

                if X_FACES[x] then
                    makeTexture(X_FACES[x]).Parent = clone
                end
                if Y_FACES[y] then
                    makeTexture(Y_FACES[y]).Parent = clone
                end
                if Z_FACES[z] then
                    makeTexture(Z_FACES[z]).Parent = clone
                end
            end
        end
    end
end

return module
