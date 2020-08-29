local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local PetDispenser = setmetatable({}, InstanceWrapper)

PetDispenser.__index = PetDispenser
PetDispenser.ClassName = script.Name

function PetDispenser.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid PetDispenser!")
    local self = setmetatable(InstanceWrapper.new(instance), PetDispenser)
    self:Log(3, "Created pet dispenser")
    self:Setup()
    return self
end

function PetDispenser:Setup()
    if self._isSetup or self._destroyed then
        return
    end
    self._isSetup = true
    local setup
    if RunService:IsClient() then
        setup = self:GetAttribute("ClientPetDispenserSetup") or script.Parent.ClientPetDispenserSetup
    else
        setup = self:GetAttribute("ServerPetDispenserSetup") or script.Parent.ServerPetDispenserSetup
    end
    require(setup)(self)
end

return PetDispenser
