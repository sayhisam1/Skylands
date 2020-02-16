return function(target, velocity_vector, maxforce_vector, duration)
	assert(type(velocity_vector) == "userdata", "Invalid velocity vector!")
	maxforce_vector = maxforce_vector or Vector3.new(10000, 10000, 10000)
	duration = duration or .1
	local bodyV = Instance.new("BodyVelocity")
	bodyV.Parent = target
	bodyV.Velocity = velocity_vector
	bodyV.P = 1000000
	bodyV.MaxForce = maxforce_vector
	bodyV.Name = "BodyFling"
	game.Debris:AddItem(bodyV, duration)
	return bodyV
end
