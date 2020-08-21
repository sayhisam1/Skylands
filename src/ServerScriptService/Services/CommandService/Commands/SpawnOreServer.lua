local ReplicatedStorage = game:GetService("ReplicatedStorage")
local OreBinder = require(ReplicatedStorage.OreBinder)
local Services = require(ReplicatedStorage.Services)

return function (context, ore)
	local clone = ore:Clone()
	clone:SetPrimaryPartCFrame(context.Executor.Character.PrimaryPart.CFrame + Vector3.new(0, 3, 0))
	clone.Parent = OreBinder:GetOresDirectory()
	local ore = OreBinder:Bind(clone)
	clone.Parent = workspace
end