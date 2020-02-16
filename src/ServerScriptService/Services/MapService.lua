--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"PlayerManager", "TeamManager"}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

local Maid = require("Maid").new()
local Services = _G.Services

local DAY_NIGHT_CYCLE_TIME = 15 -- specify time (in minutes) for a complete day/night cycle

local SPAWNER_TAG = "SPAWNER"
local CollectionService = game:GetService("CollectionService")

local Map

function Service:Load()
    Map = workspace:WaitForChild("Map")
    local Lighting = game:GetService("Lighting")
    local RunService = game:GetService("RunService")

    local mod = DAY_NIGHT_CYCLE_TIME * 60
    RunService.Heartbeat:Connect(function()
        local t = tick()
        local scale = (t % mod)/mod
        local val = math.floor(24*scale*1000)/1000
        Lighting.ClockTime = val
        local ambientScale = 1
        if (val <= 12) then
            ambientScale = val/12
        else
            ambientScale = 1 - (val%12)/12
        end
        Lighting.Ambient = Color3.fromRGB(ambientScale*186, ambientScale*177, ambientScale*147)
        Lighting.Brightness = ambientScale * 2
    end)


    local Spawners = CollectionService:GetTagged(SPAWNER_TAG)
    for _,v in pairs(Spawners) do
        local status, err = pcall(function()
            local Spawner = require("Spawner"):New(require(v.Configuration.Spawner), v.PrimaryPart.CFrame)
        end)
        if not status then warn(string.format("Load spawner %s failed with error:\n %s",v:GetFullName(), err)) end
    end
end

function Service:Unload()
end


return Service
