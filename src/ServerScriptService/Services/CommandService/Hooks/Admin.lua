local ADMINS = {game.CreatorId, 5359610, 41283451}

return function(registry)
    registry:RegisterHook(
        "BeforeRun",
        function(context)
            if context.Group == "DefaultAdmin" then
                for _, admin_id in pairs(ADMINS) do
                    if context.Executor.UserId == admin_id then
                        return nil
                    end
                end
                return "You don't have permission to run this command"
            end
        end
    )
end
