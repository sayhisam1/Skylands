local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"ClientPlayerData"}
Service:AddDependencies(DEPENDENCIES)

function Service:Load()
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:SetSetting(setting, val)
    local nc = self:GetServerNetworkChannel("PlayerSettings")
    nc:Publish("SetSetting", setting, val)
end

return Service
