local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(model)
    return Promise.new(
        function(resolve, _, onCancel)
            if not model.PrimaryPart then
                local event
                event =
                    model:GetPropertyChangedSignal("PrimaryPart"):Connect(
                    function()
                        event:Disconnect()
                        resolve(model.PrimaryPart)
                    end
                )
                onCancel(
                    function()
                        event:Disconnect()
                    end
                )
            else
                resolve(model.PrimaryPart)
            end
        end
    )
end
