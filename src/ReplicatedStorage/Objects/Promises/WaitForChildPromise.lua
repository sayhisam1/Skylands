local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Promise = require(ReplicatedStorage.Lib.Promise)

return function(instance, child)
    return Promise.new(
        function(resolve, _, onCancel)
            resolve(instance:WaitForChild(child))
        end
    )
end
