local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(instance, child)
    return Promise.new(function(resolve, _, onCancel)
        local found = instance:FindFirstChild(child)
        if not found then
            local event
            event = instance.DescendantAdded:Connect(function(descendant)
                if descendant.Name == child then
                    event:Disconnect()
                    resolve(descendant)
                end
            end)
            onCancel(
                function()
                    event:Disconnect()
                end
            )
        else
            resolve(found)
        end
    end)
end
