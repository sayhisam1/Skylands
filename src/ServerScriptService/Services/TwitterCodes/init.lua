local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local TableUtil = require(ReplicatedStorage.Utils.TableUtil)

local CODES = {}
TableUtil.foreachi(script.Codes:GetChildren(), function(i, v)
    CODES[v.Name] = require(v)
end)

function Service:Load()
    local nc = self:GetNetworkChannel()
    nc:Subscribe("TRY_ACTIVATE", function(plr, code)
        code = string.upper(tostring(code))
        code = code:gsub("%W", '') -- strip non-alpha characters
        if not CODES[code] then
            nc:Publish("RESPONSE", "Invalid code!")
            return
        end
        local RedeemedTwitterCodesStore = self.Services.PlayerData:GetStore(plr, "RedeemedTwitterCodes")
        local RedeemedCodes = RedeemedTwitterCodesStore:getState()
        if RedeemedCodes[code] then
            nc:Publish("RESPONSE", "Already redeemed!")
            return
        end
        RedeemedTwitterCodesStore:dispatch({
            type="AddItem",
            Item=code
        })
        nc:Publish("RESPONSE", CODES[code](plr))
    end)
end

return Service