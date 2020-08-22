-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {"PlayerData"}
Service:AddDependencies(DEPENDENCIES)

local CLIENT_HOOKS = Instance.new("Folder")
CLIENT_HOOKS.Parent = ReplicatedStorage
CLIENT_HOOKS.Name = "CLIENT_HOOKS"

local SHARED_INSTANCES = Instance.new("Folder")
SHARED_INSTANCES.Parent = ReplicatedStorage
SHARED_INSTANCES.Name = "SHARED_INSTANCES"

local registeredEffects = {}
function Service:Load()
    for _, v in pairs(CLIENT_HOOKS:GetChildren()) do
        if registeredEffects[v.Name] then
            v:Destroy()
            return
        end
        registeredEffects[v.Name] = v
    end
    CLIENT_HOOKS.ChildAdded:Connect(
        function(v)
            if registeredEffects[v.Name] then
                v:Destroy()
                return
            end
            registeredEffects[v.Name] = v
        end
    )
end

function Service:Unload()
    self._maid:Destroy()
end

function Service:FirePlayerClientEffect(plr, effect_name, ...)
    local channel = self:GetNetworkChannel()
    channel:PublishPlayer(plr, effect_name, ...)
end

function Service:FireClientEffectForAllPlayers(effect_name, ...)
    local channel = self:GetNetworkChannel()
    channel:Publish(effect_name, ...)
end

function Service:AddTemporarySharedInstance(instance, time)
    instance.Parent = SHARED_INSTANCES
    coroutine.wrap(
        function()
            wait(time)
            instance:Destroy()
        end
    )()
end

return Service
