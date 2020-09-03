--  Attack name should be unique within each attack context
local ATTACK_NAME = "Mining"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local OreBinder = require(ReplicatedStorage.Binders.OreBinder)
local Attack = require(ReplicatedStorage.Objects.Combat.Abstract.Attack)
local AttackPhase = require(ReplicatedStorage.Objects.Combat.Abstract.AttackPhase)
local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)

--2) Initializer function (should instantiate a new instance of the attack, given owner)
return function(tool)
    local Attack = Attack.new(ATTACK_NAME)

    local StartPhase = AttackPhase.new("START")
    local ActionPhase = AttackPhase.new("ACTION")

    local character = tool:GetCharacter()
    local player = Players:GetPlayerFromCharacter(character)
    local humanoid = character:FindFirstChild("Humanoid")
    local communicationChannel = tool:GetNetworkChannel()

    local speed = Multipliers.GetPlayerMultiplier(player, "Speed") * tool:GetAttribute("Speed")

    local AnimationChoiceYield =
        require(ReplicatedStorage.Objects.Combat.Effects.Yielding.ChannelYieldingEffect).new(
        communicationChannel,
        "ANIM",
        1 / speed / 5,
        function(effect, caller, animation)
            assert(player == caller, "Called by unexpected player!")
            local animation_effect =
                require(ReplicatedStorage.Objects.Combat.Effects.Yielding.AnimationEffect).new(animation, humanoid, nil, nil, speed * 1.1)
            animation_effect:Start()
            wait(animation_effect:GetTotalTime())
            effect:Yield()
        end
    )
    AnimationChoiceYield:SetPreemptive(true)
    ActionPhase:WithEffect(AnimationChoiceYield)

    local HitPartYield =
        require(ReplicatedStorage.Objects.Combat.Effects.Yielding.ChannelYieldingEffect).new(
        communicationChannel,
        "HIT",
        1/60,
        function(effect, caller, part, pos)
            assert(player == caller, "Called by unexpected player!")
            if not part then
                return
            end
            local ore = OreBinder:LookupInstance(part)
            if not ore and pos then
                -- add lag compensaton by predicton which block the player meant to mine
                local dirVec = (pos - caller.Character.PrimaryPart.Position).Unit
                ore = OreBinder:GetNearestOreNeighbor(dirVec * 5 + pos)
            end
            assert(ore, "Unabled to reference ore " .. part:GetFullName())
            local critChance = tool:GetAttribute("CritChance")
            local critPercentage = math.random()
            effect:PlaySound(tool:FindFirstChild("HitSound"), {Position = ore:GetCFrame().Position, IgnoredPlayers = {player}})
            if critPercentage <= critChance then
                effect:PlaySound(tool:FindFirstChild("CriticalHitSound"), {Position = ore:GetCFrame().Position, IgnoredPlayers = {player}})
                effect:PlaySound(tool:FindFirstChild("CriticalHitSound"), {OnlyPlayers = {player}})
                ore:Mine(caller, tool:GetAttribute("Damage") * 2)
            else
                ore:Mine(caller, tool:GetAttribute("Damage"))
            end
        end
    )
    ActionPhase:WithEffect(HitPartYield)

    ActionPhase:WithEffectFunction(
        function(effect)
            effect:PlaySound(tool:FindFirstChild("WooshSound"), {IgnoredPlayers = {player}, Position = player.Character.PrimaryPart.Position})
        end
    )
    local EndPhase = AttackPhase.new("END")
    Attack:AddLinearPhasePathway({StartPhase, ActionPhase, EndPhase})

    return Attack
end
