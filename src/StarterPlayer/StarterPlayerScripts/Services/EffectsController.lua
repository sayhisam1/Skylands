-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"ClientPlayerData"}
Service:AddDependencies(DEPENDENCIES)

local CLIENT_HOOKS = ReplicatedStorage:WaitForChild("CLIENT_HOOKS")

local registeredEffects = {}
function Service:Load()
    local maid = self._maid
    for _, v in pairs(CLIENT_HOOKS:GetChildren()) do
        self:RegisterEffect(v.Name, require(v))
    end
    maid:GiveTask(
        CLIENT_HOOKS.ChildAdded:Connect(
            function(child)
                self:RegisterEffect(child.Name, require(child))
            end
        )
    )
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:RegisterEffect(effect_name, handler)
    assert(type(effect_name) == "string", "Invalid effect name!")
    assert(type(handler) == "function", "Invalid handler!")
    if registeredEffects[effect_name] then
        return
    end
    self:Log(1, "Registering effect", effect_name, handler)
    registeredEffects[effect_name] = handler
    local server_channel = self:GetServerNetworkChannel("EffectsService")
    server_channel:Subscribe(effect_name, handler)
end

return Service
