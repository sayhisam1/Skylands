local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)

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

    RunService.Heartbeat:Wait()
    if instance and instance.Parent then
        instance:Destroy()
    end
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

function InstanceWrapper:GetAttribute(attribute_name)
    if not self._instance then
        return
    end
    local attribute = self:GetInstance():FindFirstChild(attribute_name)
    if attribute then
        return attribute.Value
    end
end

function InstanceWrapper:SetAttribute(attribute_name, value)
    if not self._instance then
        return
    end
    local attribute = self:GetInstance():FindFirstChild(attribute_name)
    if not attribute then
        if typeof(value) == "number" then
            attribute = Instance.new("NumberValue")
        elseif typeof(value) == "string" then
            attribute = Instance.new("StringValue")
        elseif typeof(value) == "Vector3" then
            attribute = Instance.new("Vector3Value")
        elseif typeof(value) == "boolean" then
            attribute = Instance.new("BoolValue")
        elseif value:IsA("Instance") then
            attribute = Instance.new("ObjectValue")
        end
        attribute.Name = attribute_name
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

function InstanceWrapper:GetNetworkChannel()
    if not self._instance then
        return
    end
    if not self._remoteEvent then
        if RunService:IsClient() then
            self._remoteEvent = self:GetInstance():WaitForChild("COMM_EVENT")
        else
            if self:FindFirstChild("COMM_EVENT") then
                self._remoteEvent = self:FindFirstChild("COMM_EVENT")
            else
                local re = Instance.new("RemoteEvent")
                re.Name = "COMM_EVENT"
                re.Parent = self:GetInstance()
                self._remoteEvent = re
            end
        end
    end
    if not self._networkChannel then
        self._networkChannel = NetworkChannel.new(self.Name, self._remoteEvent)
    end
    return self._networkChannel
end

return InstanceWrapper
