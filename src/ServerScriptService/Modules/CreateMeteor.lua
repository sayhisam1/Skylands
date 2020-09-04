local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local METEOR = ASSETS:WaitForChild("Meteor")
local OreBinder = require(ReplicatedStorage.Binders.OreBinder)
local MakeRobloxVal = require(ReplicatedStorage.Utils.MakeRobloxVal)

return function(name, health, goldval, gemval)
    local values = {
        MakeRobloxVal("DisplayName", name),
        MakeRobloxVal("Health", health),
        MakeRobloxVal("TotalHealth", health),
        MakeRobloxVal("Value", goldval),
        MakeRobloxVal("GemValue", gemval)
    }
    local meteor = METEOR:Clone()
    for _,v in pairs(values) do
        v.Parent = meteor
    end
    meteor.Parent = ServerStorage
    return OreBinder:Bind(meteor)
end