--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {"LocalPlayer"}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------

-----------------------------
--// CHARACTER CONSTANTS \\--
-----------------------------
local MAX_STAMINA = 100
local DOUBLE_JUMP_COST = 30
local DASH_DELAY = .3
local DASH_COST = 15
local DASH_VELOCITY = 150

-------------------------
--// LOCAL VARIABLES \\--
-------------------------
local Services = _G.Services

--local Actions = require(script.Actions)

local Maid = require("Maid").new()
local BoundEvents = {}
----------------------------------------
--// OVERRIDE RESET BUTTON BEHAVIOR \\--
----------------------------------------

function Service:Load()
    local LocalPlayer = Services.LocalPlayer
    local chan = LocalPlayer:GetChannel()
    Maid:GiveTask(
        chan:Subscribe(
            "CharacterAdded",
            function(char)
                print("CHARACTER ADDED!")
                --Actions:Unload()
                _G.Character = char
                --Actions:Load()
                local chan = self:GetChannel()
                chan:Publish("CharacterLoaded", char)
            end
        )
    )
end

local CharacterGyro = nil
function Service:RotateTo(frame, delay_time)
    if (CharacterGyro) then
        CharacterGyro:Destroy()
        CharacterGyro = nil
    end
    local character = _G.Character
    if not character then
        return
    end
    local bodyG = Instance.new("BodyGyro")
    bodyG.CFrame = frame
    bodyG.MaxTorque = Vector3.new(0, 10000, 0)
    bodyG.P = 10000
    bodyG.Parent = character.PrimaryPart
    CharacterGyro = bodyG
    delay(
        delay_time or .1,
        function()
            bodyG:Destroy()
            CharacterGyro = nil
        end
    )
end

function Service:PauseMovement()
	local MasterControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")).controls
	MasterControl:Disable() --disables movement
end

function Service:UnpauseMovement()
	local MasterControl = require(game.Players.LocalPlayer.PlayerScripts:WaitForChild("PlayerModule")).controls
	MasterControl:Enable() --enables movement
end

function Service:Unload()
    --Actions:Unload()
    for i, v in pairs(BoundEvents) do
        v:Disconnect()
    end
    BoundEvents = {}
    function self:GetStamina()
        return 0
    end
    Maid:Destroy()
    _G.Character = nil
end

function Service:GetStamina()
    return 0
end

return Service
