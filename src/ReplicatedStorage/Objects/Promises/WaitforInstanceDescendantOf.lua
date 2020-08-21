local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(instance, descendant)
    return Promise.new(
        function(resolve, _, onCancel)
            local player = instance.Parent
            if not player and not player:IsDescendantOf(descendant) then
                local event
                event =
                    instance.AncestryChanged:Connect(
                    function(_, parent)
                        if parent:IsDescendantOf(descendant) then
                            event:Disconnect()
                            resolve(instance)
                        end
                    end
                )
                onCancel(
                    function()
                        event:Disconnect()
                    end
                )
            else
                resolve(instance)
            end
        end
    )
end
