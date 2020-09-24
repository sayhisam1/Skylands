local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Services = require(ReplicatedStorage.Services)

local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)
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
        if plr and not plr:IsA("MockPlayer") then
            local backpackCapacity = Services.PlayerData:GetStore(plr, "BackpackCapacity"):getState()

            local plrOreCount = Services.PlayerData:GetStore(plr, "OreCount")
            if plrOreCount:getState() >= backpackCapacity then
                self:SetAttribute("Health", math.max(1, health - damage))
                Services.BackpackService:PromptPlayerBackpackFull(plr)
                return
            end
            plrOreCount:dispatch(
                {
                    type = "Increment",
                    Amount = 1
                }
            )

            local totalOresMined = Services.PlayerData:GetStore(plr, "TotalOresMined")
            totalOresMined:dispatch(
                {
                    type = "Increment",
                    Amount = 1
                }
            )

            if self:GetAttribute("Value") then
                local plrBackpackGoldValue = Services.PlayerData:GetStore(plr, "BackpackGoldValue")
                local value = self:GetAttribute("Value")
                value = value * Multipliers.GetPlayerMultiplier(plr, "Gold")
                plrBackpackGoldValue:dispatch(
                    {
                        type = "Increment",
                        Amount = value
                    }
                )
            end
            if self:GetAttribute("GemValue") then
                local plrGems = Services.PlayerData:GetStore(plr, "Gems")
                local value = self:GetAttribute("GemValue")
                value = value * Multipliers.GetPlayerMultiplier(plr, "Gems")
                plrGems:dispatch(
                    {
                        type = "Increment",
                        Amount = value
                    }
                )
            end
        end
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
