return function()
    -- local ReplicatedStorage = game:GetService("ReplicatedStorage")
    -- local Services = require(ReplicatedStorage.Services)
    -- local ORES = ReplicatedStorage:WaitForChild("Ores")
    -- local TEST_ORE = ORES:WaitForChild("Rubiksium")
    -- local OreBinder = require(ReplicatedStorage.Binders.OreBinder)
    -- describe(
    --     "memtest",
    --     function()
    --         itSKIP(
    --             "shouldn't leak instances",
    --             function()
    --                 for i=1,10000,1 do
    --                     local c = TEST_ORE:Clone()
    --                     c:SetPrimaryPartCFrame(CFrame.new(0,0,0))
    --                     local ore = OreBinder:AddInstance(c)
    --                     ore.Parent = OreBinder:GetSpawnedOreDirectory()
    --                     ore:Destroy()
    --                 end
    --             end
    --         )
    --     end
    -- )
end
