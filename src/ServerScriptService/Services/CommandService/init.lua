local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)

local DEPENDENCIES = {"Map"}
Service:AddDependencies(DEPENDENCIES)

local CMDR_PATH = game.ServerScriptService.Repository.Vendor.Cmdr.Server.Cmdr

function Service:Load()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")

    local Cmdr = require(CMDR_PATH)
    Cmdr:RegisterHooksIn(script.Hooks)
    Cmdr:RegisterTypesIn(script.Types)
    Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
    Cmdr:RegisterCommandsIn(script.Commands)
end

function Service:Unload()
end

return Service
