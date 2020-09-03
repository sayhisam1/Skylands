local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(tag)
    return Promise.new(
        function(resolve, _, onCancel)
            local instance = CollectionService:GetTagged(tag)
            if #instance > 0 then
                resolve(instance[1])
            else
                local event
                event =
                    CollectionService:GetInstanceAddedSignal(tag):Connect(
                    function(instance)
                        event:Disconnect()
                        resolve(instance)
                    end
                )
                onCancel(
                    function()
                        event:Disconnect()
                    end
                )
            end
        end
    )
end
