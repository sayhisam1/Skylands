local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()

local Maid = require("Maid")
local PlayerList = require("PlayerListObject")

local Effect = require("Effect")
local HitDetectingEffect = setmetatable({}, Effect)
HitDetectingEffect.__index = HitDetectingEffect
HitDetectingEffect.Name = script.Name

function HitDetectingEffect:New(owner)
    self.__index = self
    local obj = setmetatable(Effect:New(owner), self)
    obj._alreadyHit = PlayerList:New()
    obj._onPlayerHit = {}
    obj._onPartHit = {}
    return obj
end


function HitDetectingEffect:Destroy()
    self:Stop()
end

function HitDetectingEffect:HandleHit(part, pos, normal)
    local parent = (part and part.Parent)
    if parent then
        local plr = _G.Services.PlayerManager:GetPlayerByCharacter(parent)
        if plr and not self._alreadyHit:DoesContain(plr) then
            self._alreadyHit:AddPlayer(plr)
            for _, effect in pairs(self._onPlayerHit) do
                coroutine.wrap(
                    function()
                        effect:Start(plr, part, pos, normal)
                    end
                )()
            end
        end
    elseif part and part.Parent then
        for _, effect in pairs(self._onPartHit) do
            coroutine.wrap(
                function()
                    effect:Start(part, pos, normal)
                end
            )()
        end
    end
end

function HitDetectingEffect:WithPlayerHitEffect(effect)
    self._onPlayerHit[#self._onPlayerHit+1] = effect
end

function HitDetectingEffect:WithPartHitEffect(effect)
    self._onPartHit[#self._onPartHit+1] = effect
end

function HitDetectingEffect:WithPlayerHitEffectFunction(func)
    local new_effect = Effect:New(self._owner)
    new_effect:SetFunction(func)
    self:WithPlayerHitEffect(new_effect)
end

function HitDetectingEffect:WithPartHitEffectFunction(func)
    local new_effect = Effect:New(self._owner)
    new_effect:SetFunction(func)
    self:WithPartHitEffect(new_effect)
end

function HitDetectingEffect:ResetPlayerHitList()
    self._alreadyHit = PlayerList:New()
end

return HitDetectingEffect
