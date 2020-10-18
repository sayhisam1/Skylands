local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

function Service:Load()
    local nc = self:GetNetworkChannel()
    nc:Subscribe(
        "SetSetting",
        function(...)
            self:SetSetting(...)
        end
    )
end

function Service:SetSetting(plr, setting, val)
    local PlayerData = self.Services.PlayerData
    local store = PlayerData:GetStore(plr, "Settings")
    store:dispatch(
        {
            type = "SetSetting",
            Value = val,
            Setting = setting
        }
    )
end

return Service
