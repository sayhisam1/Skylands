local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(player)
    return Promise.new(
        function(resolve, _, onCancel)
            if not player.Character or not player.Character.Parent then
                local event
                event =
                    player.CharacterAdded:Connect(
                    function()
                        event:Disconnect()
                        resolve(player.Character)
                    end
                )
                onCancel(
                    function()
                        event:Disconnect()
                    end
                )
            else
                resolve(player.Character, player)
            end
        end
    )
end
