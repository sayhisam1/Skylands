local module = {}
local ORIGIN = Vector3.new(0, 0, 0)

function module.GetCubeNeighbors(n, vec, mult)
	mult = mult or 1
	local list = {}
	for x = -n, n do
		for y = -n, n do
			for z = -n, n do
				list[#list + 1] = vec + Vector3.new(x, y, z) * mult
			end
		end
	end
	return list
end

function module.GetHollowCubeNeighbors(n, vec, mult)
	mult = mult or 1
	local list = {}
	for x = -n, n do
		for y = -n, n do
			for z = -n, n do
				if math.abs(x) == n or math.abs(y) == n or math.abs(z) == n then
					list[#list + 1] = vec + Vector3.new(x, y, z) * mult
				end
			end
		end
	end
	return list
end

function module.ManhattanDist(v1, v2)
	return math.abs(v1.X - v2.X) + math.abs(v1.Y - v2.Y) + math.abs(v1.Z + v2.Z)
end

function module.GetManhattanDistanceNeighbors(n, vec, mult)
	mult = mult or 1
	local list = {}
	for x = -n, n do
		for y = -n, n do
			for z = -n, n do
				local newVec = Vector3.new(x, y, z)
				if module.ManhattanDist(ORIGIN, newVec) <= n then
					list[#list + 1] = vec + newVec * mult
				end
			end
		end
	end
	return list
end

function module.SortListByDistTo(list, vec)
	table.sort(
		list,
		function(a, b)
			return (a - vec).Magnitude < (b - vec).Magnitude
		end
	)
end

function module.MarkPoints(points)
	for _,v in pairs(points) do
		local p = Instance.new("Part")
		p.CanCollide = false
		p.Anchored =true
		p.Size = Vector3.new(.2, .2 ,.2)
		p.CFrame = CFrame.new(v)
		p.Color = Color3.new(1, 0, 0)
		p.Parent = Workspace
	end
end

return module
