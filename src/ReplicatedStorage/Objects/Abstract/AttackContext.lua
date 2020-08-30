local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BaseObject = require(ReplicatedStorage.Objects.BaseObject)
local AttackContext = setmetatable({}, BaseObject)
AttackContext.__index = AttackContext
AttackContext.ClassName = script.Name

-- Stores a context environment for attacks
-- Keeps track of running attacks, and prevents multiple attacks from running at once
function AttackContext.new()
    local self = setmetatable(BaseObject.new(), AttackContext)
    self._runningAttacks = {}
    self._coolingDownAttacks = {}
    self._enabled = false
    return self
end

local function isTableEmpty(tbl)
    for _, _ in pairs(tbl) do
        return false
    end
    return true
end

function AttackContext:CanMakeAttack(attack, is_exclusive)
    is_exclusive = is_exclusive or true
    local name = attack.Name
    if self._coolingDownAttacks[name] or self._runningAttacks[name] then
        self:Log(1, "Attack", name, "is on cooldown!")
        return false
    end
    if is_exclusive and not isTableEmpty(self._runningAttacks) then
        self:Log(1, "Attack", name, "is already running!")
        return false
    end
    return true
end

function AttackContext:MakeAttack(attack, cooldown, is_exclusive)
    if not self._enabled then
        self:Log(1, "Failed to make attack - disabled!")
        return false
    end
    cooldown = math.abs(cooldown or 0)
    is_exclusive = is_exclusive or true
    local name = attack.Name
    self:Log(1, "Attempting to make attack", name)

    if not self:CanMakeAttack(attack, is_exclusive) then
        return false
    end

    self._runningAttacks[name] = attack
    self._maid:GiveTask(
        attack.Stopped:Connect(
            function()
                self:Log(1, "Attack", name, "stopping!", tick())
                self._runningAttacks[name] = nil
                self._maid[attack] = nil
                if cooldown > 0.03 then
                    self._coolingDownAttacks[name] = tick()
                    wait(cooldown)
                    if self._coolingDownAttacks[name] then
                        self._coolingDownAttacks[name] = nil
                    end
                end
            end
        )
    )
    self._maid[name] = attack
    self:Log(1, "Attack", name, "starting!", tick())
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
