local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local AssetSetup = setmetatable({}, BaseObject)
AssetSetup.__index = AssetSetup
AssetSetup.ClassName = script.Name

function AssetSetup.new(name, required_children)
    local self = setmetatable(BaseObject.new(name), AssetSetup)
    self._tasks = {}
    for _, v in pairs(required_children or {}) do
        self:AddRequiredChild(
            v.Name,
            function()
                return v:Clone()
            end
        )
    end
    return self
end

function AssetSetup:AddSetupTask(func)
    self._tasks[#self._tasks + 1] = func
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
    local successful = {}
    for _, asset in pairs(assets) do
        self:Log(1, "\tAsset:", asset)
        if successful[asset.Name] then
            errors[asset.Name] = "Duplicate name!"
        else
            successful[asset.Name] = asset
            for _, task in pairs(self._tasks) do
                local status,
                    res = pcall(task, asset)
                if not status then
                    errors[asset.Name] = res
                    successful[asset.Name] = nil
                    break
                end
            end
        end
    end
    self:Log(3, "Done loading assets!")

    -- Asynchronously error for assets
    local be = Instance.new("BindableEvent")
    for name, msg in pairs(errors) do
        local conn = be.Event:Connect(error)
        be:Fire("Failed to setup " .. name .. " with error:\n" .. msg)
        conn:Disconnect()
    end
    be:Destroy()

    return successful
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

function AssetSetup.RecursiveFilterIgnoreRoot(root, type, ignored_types, ret)
    ignored_types = ignored_types or {"Script", "ModuleScript", "LocalScript"}
    ret = ret or {}
    for _, child in pairs(root:GetChildren()) do
        if child:IsA(type) then
            ret[#ret + 1] = child
        else
            local ignored = false
            for _, t in pairs(ignored_types) do
                if root:IsA(t) then
                    ignored = true
                    break
                end
            end
            if not ignored then
                AssetSetup.RecursiveFilter(child, type, ignored_types, ret)
            end
        end
    end

    return ret
end

return AssetSetup
