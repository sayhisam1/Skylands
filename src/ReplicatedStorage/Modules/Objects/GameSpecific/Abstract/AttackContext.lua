local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsServer = RunService:IsServer()
local IsClient = RunService:IsClient()

local AttackContext = {}
AttackContext.__index = AttackContext

-- Stores a context environment for attacks
-- Keeps track of running attacks, and prevents multiple attacks from running at once
function AttackContext:New()
    self.__index = self

    local obj = setmetatable({}, self)
    obj._runningAttacks = {}
    obj._coolingDownAttacks = {}
    obj._enabled = false

    return obj
end

local function isTableEmpty(tbl)
    for _,_ in pairs(tbl) do
        return false
    end
    return true
end

function AttackContext:MakeAttack(attack, cooldown, is_exclusive)
    if not self._enabled then return false end
    cooldown = math.abs(cooldown or 0)
    is_exclusive = is_exclusive or true
    local name = attack.Name
    if self._coolingDownAttacks[name] or self._runningAttacks[name] then
        -- warn("ATTACK STILL COOLING DOWN OR IS CURRENTLY RUNNING!")
        return false
    end
    if is_exclusive and not isTableEmpty(self._runningAttacks) then
        -- warn("ANOTHER ATTACK IS ALREADY RUNNING!")
        return false
    end

    self._runningAttacks[name] = attack
    attack.Stopped:Connect(
        function()
            self._runningAttacks[name] = nil
            if cooldown > 0.03 then
                self._coolingDownAttacks[name] = tick()
                wait(cooldown)
                if self._coolingDownAttacks[name] then
                    self._coolingDownAttacks[name] = nil
                    attack:Destroy()
                end
            end
        end
    )
    attack:Start()
    return attack
end

function AttackContext:StopAllAttacks()
    for _, attack in pairs(self._runningAttacks) do
        attack:Stop()
    end
end

function AttackContext:Enable()
    self._enabled = true
end

function AttackContext:Disable()
    self._enabled = false
    self:StopAllAttacks()
end

return AttackContext
