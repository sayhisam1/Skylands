local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ADMINS = require(ReplicatedStorage.AdminDictionary)

return function(registry)
    registry:RegisterHook(
        "BeforeRun",
        function(context)
            if context.Group == "DefaultAdmin" then
                local user_id = context.Executor.UserId
                for _, admin_id in pairs(ADMINS) do
                    if user_id == admin_id then
                        return nil
                    end
                end
                return "You don't have permission to run this command"
            end
        end
    )
end
