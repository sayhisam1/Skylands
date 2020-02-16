local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Services = _G.Services

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Maid = require("Maid")
local AttackContext = require("AttackContext")
local AttackInputBinding = setmetatable({}, AttackContext)
AttackInputBinding.__index = AttackInputBinding

-- Stores a context environment for attacks
-- Keeps track of running attacks, and prevents multiple attacks from running at once
function AttackInputBinding:New(network_channel)
    self.__index = self

    assert(type(network_channel) == "table", "Invalid network channel provided!")
    local obj = setmetatable(AttackContext:New(), self)
    obj._networkChannel = network_channel
    obj._boundAttacks = {}
    obj._maids = {}

    return obj
end

function AttackInputBinding:BindAttack(owner, attack_intializer, input_name, desired_input_state)
    desired_input_state = desired_input_state or true
    local name = input_name
    assert(self._boundAttacks[name] == nil, "Tried to bind attack to already bound input "..name)
    self._boundAttacks[name] = attack_intializer
    
    local attack_maid = Maid.new()
    local task =
        self:_bindInputToFunc(
        owner,
        input_name,
        desired_input_state,
        function(...)
            self:MakeAttack(attack_intializer(owner, self._networkChannel, input_name))
        end
    )

    attack_maid:GiveTask(task)
    self._maids[name] = attack_maid
    return name
end

function AttackInputBinding:UnbindAttack(input_name)
    if self._maids[input_name] then
        self._maids[input_name]:Destroy()
    end
    self._maids[input_name] = nil
    self._boundAttacks[input_name] = nil
end

function AttackInputBinding:UnbindAll()
    for _,input_name in pairs(self._boundAttacks) do
        self:UnbindAttack(input_name)
    end
end
function AttackInputBinding:GetBoundAttack(input_name)
    return self._boundAttacks[input_name]
end

function AttackInputBinding:_bindInputToFunc(owner, input_name, desired_input_state, func)
    desired_input_state = desired_input_state or true
    local input_channel = (IsClient and Services.InputService:GetChannel()) or self._networkChannel
    local handler
    if IsClient then
        handler = function(pressed_down, ...)
            if self._enabled then
                self._networkChannel:Publish(input_name, pressed_down, _G.Clock:GetTime())
                if pressed_down == desired_input_state then
                    func(...)
                end
            end
        end
    elseif IsServer then
        handler = function(plr, pressed_down, ...)
            if self._enabled and plr == owner:GetReference() and pressed_down == desired_input_state then
                func(...)
            end
        end
    end
    local task = input_channel:Subscribe(input_name, handler)
    return task
end

function AttackInputBinding:Destroy()
    self:Disable()
    self:UnbindAll()
    for idx, maid in pairs(self._maids) do
        maid:Destroy()
        self._maids[idx] = nil
    end
end

return AttackInputBinding
