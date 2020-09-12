-- stores player inventories --

local GroupService = game:GetService("GroupService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local GROUP_ID = 4981238
local TESTER_GROUP_RANK = 10
function Service:Load()
    self:HookPlayerAction(function(plr)
        if RunService:IsStudio() then
            return
        end
        local groups = GroupService:GetGroupsAsync(plr.UserId)
        for _, v in pairs(groups) do
            if v.Id == GROUP_ID and v.Rank >= TESTER_GROUP_RANK then
                return
            end
        end
        plr:Kick("You are not a beta tester - sorry!")
    end)
end

function Service:Unload()
    self._maid:Destroy()
end

return Service
