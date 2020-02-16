--Tool object is the main controller for tools

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))
while not _G.Services do wait() end
local Services = _G.Services

local NetworkChannel = require("NetworkChannel")
local Channel = require("Channel")
local Maid = require("Maid")
local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Tool = {}
local AttackInputBinding = require("AttackInputBinding")

local Welding = require("Welding")

Tool.__index = Tool
function Tool:New()
    self.__index = self
    local obj = setmetatable({}, self)

    obj._channels = {}
    obj._maid = Maid.new()
    return obj
end

function Tool:Destroy()
    self._maid:Destroy()
    self:ClearOwner()
    if self.ToolModel then
        self.ToolModel:Destroy()
    end
    for i, v in pairs(self) do
        self[i] = nil
    end
end

function Tool:Instantiate(tool_model, always_equipped)
    self.ToolModel = tool_model

    self:_weldParts()
    self._equipped = false

    -- self._maid:GiveTask(
    --     self.ToolModel:GetPropertyChangedSignal("Parent"):Connect(
    --         function(property)
    --             local parent = self.ToolModel.Parent
    --             if not parent then
    --                 self:Destroy()
    --             end
    --             self:_detectOwner()
    --         end
    --     )
    -- )
    self._maid:GiveTask(
        self.ToolModel.Equipped:Connect(function()
            local parent = self.ToolModel.Parent
            if not parent then
                self:Destroy()
            end
            self:_detectOwner()
        end)
    )
    self._maid:GiveTask(
        self.ToolModel.Unequipped:Connect(function()
            local parent = self.ToolModel.Parent
            if not parent then
                self:Destroy()
            end
            self:_detectOwner()
        end)
    )
    if always_equipped then
        self._alwaysEquipped = true
        while not self.ToolModel.Parent.Name == "Backpack" do wait() end
        self:_detectOwner()
        self:Equip(self._owner)
    end
end

function Tool:_replaceWeldWithMotor6D()
    if not self.ToolModel.RequiresHandle then return end
    if IsClient then return end
    local char = self.ToolModel.Parent
    local rHand = char:WaitForChild("RightHand",1)
    if rHand then
        local grip = rHand:WaitForChild("RightGrip",1)
        if grip then
            local m6d = Instance.new("Motor6D")
            m6d.Parent = rHand
            m6d.Name = "RightGrip"
            m6d.Part0 = grip.Part0
            m6d.Part1 = grip.Part1
            m6d.C0 = grip.C0
            m6d.C1 = grip.C1
            self._m6d = m6d
            grip:Destroy()
        end
    end
end

function Tool:Equip(owner)
    if self._equipped then
        return
    end
    self:SetOwner(owner)
    self:_bindAttacks()
    self._attackInputContext:Enable()
    self._equipped = true
    self:_replaceWeldWithMotor6D()
end

function Tool:Unequip()
    if not self._equipped then
        return
    end
    self._equipped = false
    if self._m6d then
        self._m6d:Destroy()
        self._m6d = nil
    end
    self._attackInputContext:Destroy()
    self._attackInputContext = nil
end

function Tool:SetOwner(owner)
    assert(type(owner) == "table" and type(owner.GetId) == "function", string.format("Invalid owner provided! (Given %s, with type %s)",tostring(owner),type(owner)))
    self._owner = owner
    --self:SetCharacter(owner:GetCharacter())
end

function Tool:ClearOwner()
    self._owner = nil
    self:ClearCharacter()
end

function Tool:SetCharacter(char)
    assert(char:IsA("Model"), "Invalid character!")
    local setting = self:_getSetting("Character", "ObjectValue")
    setting.Value = char
    return char
end

function Tool:ClearCharacter()
    local setting = self:_getSetting("Character", "ObjectValue")
    setting.Value = nil
end

function Tool:_weldParts()
    local handle = self.ToolModel:FindFirstChild("Handle")
    if handle then
        -- for _, child in pairs(handle:GetChildren()) do
        --     if child:IsA("JointInstance") then
        --         child:Destroy()
        --     end
        -- end
        local parts = self.ToolModel:FindFirstChild("Parts")
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

function Tool:_bindAttacks()
    local attack_input_context =
        self._attackInputContext or AttackInputBinding:New(self:_getNetworkChannel("Input", IsClient))
    self._attackInputContext = attack_input_context

    local attack_table = self.ToolModel:FindFirstChild("Attacks")
    if not attack_table then
        return
    end
    for _, attack_data in pairs(require(attack_table)) do
       attack_input_context:BindAttack(self._owner, attack_data.Initializer, attack_data.InputName, attack_data.DesiredInputState)
    end

    self._maid:GiveTask(attack_input_context)
end

function Tool:_getSetting(setting_name, setting_type)
    local settings_folder = self:_getFolder("Settings")
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
function Tool:_getRemoteEvent(event_name)
    local remotes = self:_getFolder("Remotes")
    if IsServer then
        local remote_event = remotes:FindFirstChild(event_name)
        if not remote_event then
            remote_event = Instance.new("RemoteEvent")
            remote_event.Name = event_name
            remote_event.Parent = remotes
            self._maid:GiveTask(remote_event)
        end
        return remote_event
    elseif IsClient then
        return remotes:WaitForChild(event_name)
    end
end

function Tool:_getNetworkChannel(channel_name, call_on_caller)
    local channel = self._channels[channel_name]
    if not channel then
        self._channels[channel_name] =
            NetworkChannel:New(channel_name, self:_getRemoteEvent(channel_name), call_on_caller)
        channel = self._channels[channel_name]
        self._maid:GiveTask(channel)
    end
    return channel
end
function Tool:_getFolder(folder_name)
    if IsServer then
        local folder = self.ToolModel:FindFirstChild(folder_name)
        if not folder then
            folder = Instance.new("Folder")
            folder.Name = folder_name
            folder.Parent = self.ToolModel
            self._maid:GiveTask(folder)
        end
        return folder
    elseif IsClient then
        return self.ToolModel:WaitForChild(folder_name)
    end
end

return Tool
