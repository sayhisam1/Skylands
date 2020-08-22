local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if not RunService:IsRunning() then
    print("MOCK SERVICES")
    return require(ReplicatedStorage.Objects.Shared.Services.MockServices)
end

while not _G.Services do
    wait()
end

return _G.Services
