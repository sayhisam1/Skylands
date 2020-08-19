local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local AssetSetup = setmetatable({}, BaseObject)
AssetSetup.__index = AssetSetup
AssetSetup.ClassName = script.Name

function AssetSetup.new(name, required_children)
    local self = setmetatable(BaseObject.new(name), AssetSetup)
    self._tasks = {}
    for _, v in pairs(required_children or {}) do
        self:AddRequiredChild(v.Name, function()
            return v:Clone()
        end)
    end
    return self
end

function AssetSetup:AddSetupTask(func)
    self._tasks[#self._tasks+1] = func
end

function AssetSetup:AddRequiredChild(name, getter)
    local func = function(asset)
        if not asset:FindFirstChild(name) then
            local newVal = getter(asset)
            newVal.Name = name
            newVal.Parent = asset
        end
    end
    self:AddSetupTask(func)
end

function AssetSetup:Setup(assets)
    self:Log(1, "Setting up", assets)
    local errors = {}
    for _, asset in pairs(assets) do
        self:Log(1, "\tAsset:", asset)
        for _, task in pairs(self._tasks) do
            local status, res = pcall(task, asset)
            if not status then
                errors[asset.Name] = res
                break
            end
        end
    end
    self:Log(3, "Done loading assets!")
    local be = Instance.new("BindableEvent")
    for name, msg in pairs(errors) do
        local conn = be.Event:Connect(error)
        be:Fire("Asset setup task for "..name.." failed with error:\n"..msg)
        conn:Disconnect()
    end
    be:Destroy()
end


function AssetSetup.RecursiveFilter(root, type, ignored_types, ret)
    ignored_types = ignored_types or {"Script", "ModuleScript", "LocalScript"}
    ret = ret or {}
    if root:IsA(type) then
        ret[#ret + 1] = root
    else
        for _, t in pairs(ignored_types) do
            if root:IsA(t) then
                return ret
            end
        end
        for _, child in pairs(root:GetChildren()) do
            AssetSetup.RecursiveFilter(child, type, ignored_types, ret)
        end
    end

    return ret
end

return AssetSetup