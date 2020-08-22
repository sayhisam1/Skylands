--  Attack name should be unique within each attack context
local ATTACK_NAME = "Mining"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Attack = require(ReplicatedStorage.Objects.Combat.Abstract.Attack)
local AttackPhase = require(ReplicatedStorage.Objects.Combat.Abstract.AttackPhase)
local Effect = require(ReplicatedStorage.Objects.Combat.Abstract.Effect)
local MiningUtil = require(ReplicatedStorage.Utils.MiningUtil)
local Multipliers = require(ReplicatedStorage.StoreWrappers.Multipliers)

--2) Initializer function (should instantiate a new instance of the attack, given owner)
return function(tool)
    local Attack = Attack.new(ATTACK_NAME)

    local StartPhase = AttackPhase.new("START")
    local ActionPhase = AttackPhase.new("ACTION")

    local character = game.Players.LocalPlayer.Character
    local character_humanoid = character.Humanoid
    assert(tool:GetCharacter() == character, "Tried to run mine on different character!")
    local communicationChannel = tool:GetNetworkChannel()

    local miningAnim =
        (tool:GetAttribute("LastMiningAnim") == 2 and tool:FindFirstChild("MiningAnimation1")) or tool:FindFirstChild("MiningAnimation2")

    local speed = Multipliers.GetMultiplier("Speed") * tool:GetAttribute("Speed")
    local animation_effect =
        require(ReplicatedStorage.Objects.Combat.Effects.Yielding.AnimationEffect).new(miningAnim, character_humanoid, nil, nil, speed)
    ActionPhase:WithEffect(animation_effect)

    ActionPhase:WithEffectFunction(
        function()
            communicationChannel:Publish("ANIM", miningAnim)
            if tool:GetAttribute("LastMiningAnim") == 2 then
                tool:SetAttribute("LastMiningAnim", 1)
            else
                tool:SetAttribute("LastMiningAnim", 2)
            end
        end
    )

    ActionPhase:WithEffectFunction(
        function(effect)
            effect:PlaySound(tool:FindFirstChild("WooshSound"), {PitchShift = .9 + math.random() * .2})
        end
    )

    local OnSwingEffect = Effect.new()
    OnSwingEffect:SetFunction(
        function(effect)
            local origin = tool:GetCharacter().PrimaryPart.Position
            local range = tool:GetAttribute("Range")
            local ore = MiningUtil.GetTargetOre(origin, range)
            if ore and ore:IsMineable() then
                effect:PlaySound(tool:FindFirstChild("HitSound"), {PitchShift = .9 + math.random() * .2})
                communicationChannel:Publish("HIT", ore:GetInstance(), ore:GetCFrame().Position)
            else
                communicationChannel:Publish("HIT", nil)
            end
        end
    )

    animation_effect:BindKeyframeEffect(OnSwingEffect, "Swing") -- starts running the hit effect at the "Swing" keyframe of the animation

    local EndPhase = AttackPhase.new("END")

    Attack:AddLinearPhasePathway({StartPhase, ActionPhase, EndPhase})

    return Attack
end
