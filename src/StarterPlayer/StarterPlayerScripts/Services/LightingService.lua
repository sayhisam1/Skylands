--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

local lighting = game:GetService("Lighting")

local STORAGE_DIR = lighting
local LightingObject = require("LightingObject")
local lightingEffects
local connections = {}

local lightingAttributes = {
    "Brightness",
    "Ambient",
    "FogColor",
    "FogEnd",
    "FogStart",
    "ExposureCompensation"
}

local Binds = {}
function Service:Load()
    for i, v in pairs(Binds) do
        v:Disconnect()
        Binds[i] = nil
    end
    Binds = {}
    if (lightingEffects) then
        lightingEffects:Destroy()
    end
    local v = STORAGE_DIR:FindFirstChild("LightingEffects")
    while (v) do
        v:Destroy()
        v = STORAGE_DIR:FindFirstChild("LightingEffects")
    end
    lightingEffects = Instance.new("Folder")
    lightingEffects.Parent = STORAGE_DIR
    lightingEffects.Name = "LightingEffects"
    Binds[#Binds + 1] =
        lightingEffects.ChildAdded:Connect(
        function(c)
            for i, v in pairs(c:GetChildren()) do
                if (v:IsA("Color3Value") or v:IsA("NumberValue")) then
                    v.Changed:Connect(
                        function()
                            self:RecalculateAttribute(v.Name)
                        end
                    )
                end
            end
            Binds[#Binds + 1] =
                c.ChildAdded:Connect(
                function(v)
                    if (v:IsA("Color3Value") or v:IsA("NumberValue")) then
                        Binds[#Binds + 1] =
                            v:GetPropertyChangedSignal("Value"):Connect(
                            function()
                                self:RecalculateAttribute(v.Name)
                            end
                        )
                        self:RecalculateAttribute(v.Name)
                    end
                end
            )
            Binds[#Binds + 1] =
                c.ChildRemoved:Connect(
                function(v)
                    self:RecalculateAttribute(v.Name)
                end
            )
            self:RecalculateLighting()
        end
    )
end

function Service:Unload()
    for i, v in pairs(Binds) do
        v:Disconnect()
        Binds[i] = nil
    end
    Binds = {}
    if (lightingEffects) then
        lightingEffects:Destroy()
    end
    local v = STORAGE_DIR:FindFirstChild("LightingEffects")
    while (v) do
        v:Destroy()
        v = STORAGE_DIR:FindFirstChild("LightingEffects")
    end
end

function Service:RegisterSkyEffect(effect)
    effect.Parent = lightingEffects
end
function Service:RecalculateLighting()
    local children = lightingEffects:GetChildren()
    local attr = LightingObject:New()
    for i, v in pairs(children) do
        if v:IsA("Folder") then
            for j, k in pairs(v:GetChildren()) do
                attr:AddValue(k.Name, k.Value)
            end
        end
    end
    attr:CalculateValues()
    attr:ApplyValues()
end

function Service:RecalculateAttribute(attr_name)
    local children = lightingEffects:GetChildren()
    local attr = LightingObject:New()
    for i, v in pairs(children) do
        if v:IsA("Folder") then
            local k = v:FindFirstChild(attr_name)
            if (k) then
                attr:AddValue(k.Name, k.Value)
            end
        end
    end
    attr:CalculateValues()
    attr:ApplyValues()
end

return Service
