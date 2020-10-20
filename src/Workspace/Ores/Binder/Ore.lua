local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceWrapper = require(ReplicatedStorage.Objects.Shared.InstanceWrapper)
local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)
local Ore = setmetatable({}, InstanceWrapper)

Ore.__index = Ore
Ore.ClassName = script.Name

function Ore.new(instance)
    assert(type(instance) == "userdata" and instance:IsA("Model"), "Invalid Ore!")
    local self = setmetatable(InstanceWrapper.new(instance), Ore)

    return self
end

function Ore:IsMineable()
    return not self:GetAttribute("Unmineable") and not self._destroyed
end

function Ore:SetCFrame(cframe)
    if self._destroyed then
        return
    end
    self:GetInstance():SetPrimaryPartCFrame(cframe)
end

function Ore:GetCFrame()
    return self:GetInstance().PrimaryPart.CFrame
end

function Ore:Mine(plr, damage)
    if not self:IsMineable() then
        return
    end
    local health = self:GetAttribute("Health")
    self:Log(1, "Plr", plr, "Dealing", damage, "damage to ore", self:GetInstance():GetFullName(), "with health", self:GetAttribute("Health"))
    assert(type(plr) == "userdata", "Invalid player!")
    assert(type(damage) == "number", string.format("Invalid damage!", tostring(damage)))
    assert(type(health) == "number", string.format("Invalid ore health! (type:%s)", type(health)))
    self:SetAttribute("Health", math.max(0, health - damage))

    if self:GetAttribute("Health") <= 0 then
        local sfx = Effect.new()
        sfx:SetFunction(
            function(effect)
                local sound = self:GetInstance():FindFirstChild("BreakSound")
                if sound then
                    effect:PlaySound(sound, {Position = self:GetCFrame().Position})
                end
            end
        )
        sfx:Start()
        self:RunModule("Mined", plr, damage)
        self:Destroy()
    else
        self:RunModule("Damaged", plr, damage)
        local sfx = Effect.new()
        sfx:SetFunction(
            function(effect)
                local sound = self:GetInstance():FindFirstChild("HitSound")
                if sound then
                    effect:PlaySound(sound, {Position = self:GetCFrame().Position})
                end
            end
        )
        sfx:Start()
    end
end

return Ore
