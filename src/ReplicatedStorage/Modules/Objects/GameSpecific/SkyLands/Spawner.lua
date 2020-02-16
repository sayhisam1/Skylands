local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local CollectableNPC = require("CollectableNPC")
local RunService = game:GetService("RunService")
local IsClient = RunService:IsClient()
local IsServer = RunService:IsServer()
local HttpService = game:GetService("HttpService")
local Maid = require("Maid")

local Spawner = {}
Spawner.__index = Spawner
Spawner.ClassName = script.Name

function Spawner:New(config, cframe)
    assert(type(config) == 'table', "Invalid spawner config!")
    assert(type(cframe) == 'userdata', "Invalid spawn cframe!")
    local obj = setmetatable({}, self)
    obj._npc = CollectableNPC:New(HttpService:GenerateGUID(false))
    local DEFAULT_BOT_TEAM = _G.Services.TeamManager:GetDefaultBotTeam()
    DEFAULT_BOT_TEAM:AddMember(obj._npc)
    obj._npc.AutoRespawn = false
    obj._npc:SetRespawnTime(config.RespawnTime)
    obj._npc:SetSpawnCFrame(cframe)
    local conn = obj._npc:BindEvent("Death", function()
        wait(config.RespawnTime)
        obj:RerollNextSpawnChoice()
        obj._npc:LoadCharacter(cframe)
    end)
    _G.Services.PlayerManager:AddPlayer(obj._npc)
    obj._choices = config.Choices
    obj:RerollNextSpawnChoice()
    obj._npc:LoadCharacter(cframe)
    return obj
end

function Spawner:LoadChoice(choice)
    -- load model
    local category = choice.Category
    local type = choice.Type
    local model = _G.Services.AssetManager:GetAsset(category, type)
    self._npc:SetDefaultCharacter(model)
    local moduleList = choice.Modules or {}
    self._npc:SetModuleList(moduleList)
end

function Spawner:RerollNextSpawnChoice()
    local rand = math.random(0, 100)
    local curr = 0
    for _,choice in pairs(self._choices) do
        curr = curr + choice.Rarity
        if rand <= curr then
            self:LoadChoice(choice)
            return
        end
    end
end

return Spawner
