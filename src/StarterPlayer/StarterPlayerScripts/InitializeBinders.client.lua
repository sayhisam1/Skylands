local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BINDERS = ReplicatedStorage.Binders

for _, v in pairs(BINDERS:GetChildren()) do
    require(v)
end
BINDERS.ChildAdded:Connect(
    function(child)
        require(child)
    end
)
