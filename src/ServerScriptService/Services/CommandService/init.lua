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
-- This is a script you would create in ServerScriptService, for example.
local ServerScriptService = game:GetService("ServerScriptService")
local HOOKS = script:WaitForChild("Hooks")
local Cmdr = require(ServerScriptService.Repository.Vendor.Cmdr.Server.Cmdr)
Cmdr:RegisterDefaultCommands() -- This loads the default set of commands that Cmdr comes with. (Optional)
Cmdr:RegisterHooksIn(HOOKS)
function Service:Load()
end

function Service:Unload()
end

return Service
