local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rodux = require(ReplicatedStorage.Lib.Rodux)
local Null = require(ReplicatedStorage.Objects.Shared.Null)

return setmetatable({
    ClientPlayerData = {
        GetStore = function(key)
            return Null
        end
    }
}, Null)