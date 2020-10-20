local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local WaitForChildPromise = require(ReplicatedStorage.Objects.Promises.WaitForChildPromise)
local MakeRobloxVal = require(ReplicatedStorage.Utils.MakeRobloxVal)
local InstanceWrapper = setmetatable({}, BaseObject)

InstanceWrapper.__index = InstanceWrapper
InstanceWrapper.ClassName = script.Name

function InstanceWrapper.new(instance)
    assert(type(instance) == "userdata", "Invalid InstanceWrapper!")

    local self = setmetatable(BaseObject.new(instance.Name), InstanceWrapper)

    self._instance = instance

    return self
end

function InstanceWrapper:Destroy()
    if self._destroyed then
        return
    end
    self._destroyed = true
    self:RunModule("Destroyed")
    self._maid:Destroy()
    local instance = self._instance
    self._instance = nil

    coroutine.wrap(
        function()
            RunService.Heartbeat:Wait()
            if instance and instance.Parent then
                instance:Destroy()
            end
        end
    )()
end

function InstanceWrapper:SetCFrame(cframe)
    error("SetCFrame Unimplemented!")
end

function InstanceWrapper:GetCFrame()
    error("GetCFrame Unimplemented!")
end

function InstanceWrapper:GetInstance()
    return self._instance
end

function InstanceWrapper:FindFirstChild(...)
    if not self._instance then
        return
    end
    return self:GetInstance():FindFirstChild(...)
end

function InstanceWrapper:WaitForChildPromise(child)
    local promise = WaitForChildPromise(self:GetInstance(), child)
    self._maid:GiveTask(
        function()
            promise:cancel()
        end
    )
    return promise
end

function InstanceWrapper:GetAttribute(attribute_name)
    if not self._instance then
        return
    end
    local attribute = self:GetInstance():FindFirstChild(attribute_name)
    if attribute then
        if attribute:IsA("ModuleScript") then
            return attribute
        end
        return attribute.Value
    end
end

function InstanceWrapper:SetAttribute(attribute_name, value)
    if not self._instance then
        return
    end
    local attribute = self:GetInstance():FindFirstChild(attribute_name)
    if not attribute then
        attribute = MakeRobloxVal(attribute_name, value)
        attribute.Parent = self:GetInstance()
    end
    attribute.Value = value
end

function InstanceWrapper:RunModule(module_name, ...)
    local module = self:GetAttribute(module_name)
    if module then
        assert(module:IsA("ModuleScript"), "Invalid module " .. module_name .. "!")
        local success,
            res =
            pcall(
            function(...)
                local req = require(module)
                if typeof(req) == "function" then
                    return req(self, ...)
                elseif req.Run then
                    return req:Run(self, ...)
                end
                error("Module is not runnable!")
            end,
            ...
        )
        if not success then
            local be = Instance.new("BindableEvent")
            be.Event:Connect(error)
            be:Fire(self:GetLogPrefix() .. "Run module " .. module_name .. " failed with error:\n" .. res)
            be:Destroy()
        else
            return res
        end
    end
end

return InstanceWrapper
