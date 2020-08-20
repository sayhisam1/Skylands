-- stores player inventories --

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Service = require(ReplicatedStorage.Objects.Shared.Services.ServiceObject).new(script.Name)
local DEPENDENCIES = {}
Service:AddDependencies(DEPENDENCIES)

local BINDERS = {ReplicatedStorage.OreBinder, ReplicatedStorage.PickaxeBinder, ReplicatedStorage.BackpackBinder, ReplicatedStorage.PetBinder}
for _,v in pairs(BINDERS) do
    require(v)
end
return Service
