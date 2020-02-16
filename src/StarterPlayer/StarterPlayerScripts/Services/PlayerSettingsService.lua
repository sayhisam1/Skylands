--------------------------------------
--// STANDARD SERVICE DECLARATION \\--
--// TEMPLATE					  \\--
--------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require = require(ReplicatedStorage:WaitForChild("Nevermore"))

local Service = require("ServiceObject"):New(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)
---------------------------
--// TEMPLATE FINISHED \\--
---------------------------
local InputObject = require("InputObject")

local DefaultSettings = {
    Inputs = {
        Movement = {
            Sprint = {InputObject:New(Enum.KeyCode.LeftShift)},
            Jump = {InputObject:New(Enum.KeyCode.Space)},
            Left = {InputObject:New(Enum.KeyCode.A)},
            Right = {InputObject:New(Enum.KeyCode.D)},
            Forwards = {InputObject:New(Enum.KeyCode.W)},
            Backwards = {InputObject:New(Enum.KeyCode.S)}
        },
        Action = {
            PrimaryAttack = {InputObject:New(Enum.UserInputType.MouseButton1)},
            SecondaryAttack = {InputObject:New(Enum.KeyCode.Q)},
            SpringBoots = {InputObject:New(Enum.KeyCode.E)},
            SpecialTwo = {InputObject:New(Enum.KeyCode.R)},
            SpecialThree = {InputObject:New(Enum.KeyCode.F)},
            SpecialFour = {InputObject:New(Enum.KeyCode.C)},
            Defend = {InputObject:New(Enum.KeyCode.T)}
            -- EquipOne = {InputObject:New(Enum.KeyCode.One)},
            -- EquipTwo = {InputObject:New(Enum.KeyCode.Two)},
            -- EquipThree = {InputObject:New(Enum.KeyCode.Three)},
            -- EquipFour = {InputObject:New(Enum.KeyCode.Four)},
            -- EquipFive = {InputObject:New(Enum.KeyCode.Five)},
            -- EquipSix = {InputObject:New(Enum.KeyCode.Six)},
            -- EquipSeven = {InputObject:New(Enum.KeyCode.Seven)},
            -- EquipEight = {InputObject:New(Enum.KeyCode.Eight)},
            -- EquipNine = {InputObject:New(Enum.KeyCode.Nine)},
            -- EquipZero = {InputObject:New(Enum.KeyCode.Zero)}
        }
    }
}
local Settings = DefaultSettings

function Service:Load()
    Settings = DefaultSettings
end

function Service:Unload()
end

function Service:GetInputSettings()
    return Settings["Inputs"]
end

return Service
