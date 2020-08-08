--Tool object is the main controller for tools
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetworkChannel = require(ReplicatedStorage.Objects.Shared.NetworkChannel)
local Channel = require(ReplicatedStorage.Objects.Shared.Channel)
local Maid = require(ReplicatedStorage.Objects.Shared.Maid)
local Event = require(ReplicatedStorage.Objects.Shared.Event)
local Welding = require(ReplicatedStorage.Utils.Welding)

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()


local ToolUtil = {}

function ToolUtil.ReplaceGripWithMotor6D(tool, handle_part, motor6d_name)
    if IsClient then return end
    handle_part = handle_part or tool["Handle"]
    motor6d_name = weld_name or "RightGrip"
    local char = tool.Parent
    local rHand = char:FindFirstChild("RightHand")
    for _, child in pairs(rHand:GetChildren()) do
        if child:IsA("Motor6D") and child.Name == "RightGrip" then
            child:Destroy()
        end
    end
    local m6d = Instance.new("Motor6D")
    m6d.Parent = rHand
    m6d.Name = motor6d_name
    m6d.Part0 = rHand
    m6d.Part1 = handle_part
    m6d.C0 = CFrame.new(0,0,-1) * CFrame.Angles(-math.pi/2,0,0) * CFrame.Angles(0,math.pi/2,0)
    -- m6d.C1 = grip.C1
end

function ToolUtil.WeldParts(tool, rootpart)
    local handle = rootpart or tool:FindFirstChild("Handle")
    if handle then
        local parts = tool:FindFirstChild("Parts")
        if parts then
            for _, part in pairs(parts:GetChildren()) do
                local needToCreate = true
                for _, child in pairs(handle:GetChildren()) do
                    if child:IsA("JointInstance") then
                        if child.Part0 == part or child.Part1 == part then
                            needToCreate = false
                        end
                    end
                end
                if needToCreate then
                    local weld = Welding.weldTogether(handle, part)
                end
            end
        end
    end
end


function ToolUtil.GetSetting(tool, setting_name, setting_type)
    local settings_folder = ToolUtil.GetFolder(tool, "Settings")
    if IsServer then
        local settings = settings_folder:FindFirstChild(setting_name)
        if not settings then
            settings = Instance.new(setting_type)
            settings.Name = setting_name
            settings.Parent = settings_folder
        end
        return settings
    elseif IsClient then
        return settings_folder:WaitForChild(setting_name)
    end
end
function ToolUtil.GetRemoteEvent(tool, event_name)
    local remotes = ToolUtil.GetFolder("Remotes")
    if IsServer then
        local remote_event = remotes:FindFirstChild(event_name)
        if not remote_event then
            remote_event = Instance.new("RemoteEvent")
            remote_event.Name = event_name
            remote_event.Parent = remotes
        end
        return remote_event
    elseif IsClient then
        return remotes:WaitForChild(event_name)
    end
end

function ToolUtil.GetNetworkChannel(tool, channel_name, call_on_caller)
    return NetworkChannel.new(channel_name, ToolUtil.GetRemoteEvent(tool, channel_name), call_on_caller)
end

function ToolUtil.GetFolder(tool, folder_name)
    if IsServer then
        local folder = tool:FindFirstChild(folder_name)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folder_name
            folder.Parent = tool
        end
        return folder
    elseif IsClient then
        return tool:WaitForChild(folder_name)
    end
end

return ToolUtil
