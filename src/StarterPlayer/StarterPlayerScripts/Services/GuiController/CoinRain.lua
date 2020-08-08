local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ASSETS = ReplicatedStorage:WaitForChild("Assets")
local COIN_MODEL = ASSETS:WaitForChild("Coin")
local COIN_SOUND = ASSETS:WaitForChild("CoinSound")

local module = {}

function module:Run(plr)
    coroutine.wrap(
        function()
            COIN_SOUND:Play()
            for i = 1, math.random(10, 15) do
                local nc = COIN_MODEL:Clone()
                nc:SetPrimaryPartCFrame(
                    plr.Character.PrimaryPart.CFrame +
                        Vector3.new(math.random(-4, 4), math.random(8, 12), math.random(-4, 4))
                )
                nc.PrimaryPart.RotVelocity = Vector3.new(math.random(-100,100), 100, math.random(-100,100))
                nc.Parent = workspace
                game.Debris:AddItem(nc, 5)
                wait()
            end
        end
    )()
end

return module
