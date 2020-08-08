local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(ReplicatedStorage.Lib.Roact)

return function(target)
    local gui = require(script.Parent)
    local handle = Roact.mount(gui, target)
    return function()
        Roact.unmount(handle)
    end
end