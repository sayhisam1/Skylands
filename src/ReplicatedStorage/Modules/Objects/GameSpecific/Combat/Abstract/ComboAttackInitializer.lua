--[[
	ComboAttack class
	Defines a combo attack by combining attacks together
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local Event = require(ReplicatedStorage.Modules.Objects.Shared.Event)

local FSM = require("EventDrivenFSM")
local State = require("State")
local EventTransition = require("EventTransition")
local Maid = require("Maid")

local ComboAttack = {}

ComboAttack.__index = ComboAttack
ComboAttack.__call = function(self, owner, input_channel, input_name)
    local currTime = tick()
    if (currTime - self._lastInitialization) > self._timeout or self._currentAttack > #self._initializers then
        self._currentAttack = 1
    end
    self._lastInitialization = currTime
    local newAttack = self._initializers[self._currentAttack](owner, input_channel, input_name)
    newAttack.Started:Connect(function()
        self._currentAttack = self._currentAttack + 1
        self._lastInitialization = tick()
    end)
    --print("COMBO STATE",self._currentAttack)
    return newAttack
end
function ComboAttack:New(timeout,...)
    self.__index = self
    local obj = setmetatable({}, self)

    obj._initializers = {}
    obj._timeout = timeout or .5
    obj._currentAttack = 1
    obj._lastInitialization = -1
    for _,initializer in pairs({...}) do
        obj:AddAttackInitializer(initializer)
    end
    return obj
end

function ComboAttack:AddAttackInitializer(attack_initializer)
    self._initializers[#self._initializers + 1] = attack_initializer
end

return ComboAttack
