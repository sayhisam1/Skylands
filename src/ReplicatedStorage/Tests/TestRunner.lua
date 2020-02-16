local TestEZ = require(script.Parent.TestEZ)
local RunService = game:GetService("RunService")

local runners = {}

function runners:RunAll()
    while not (_G.Services) do
        wait(.1)
    end
    TestEZ.TestBootstrap:run(script.Parent.ModuleTests:GetChildren())
    -- TestEZ.TestBootstrap:run({script.Parent.ModuleTests:FindFirstChild("Attack.spec")})
end

return runners
