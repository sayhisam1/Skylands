local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TableUtil = require(ReplicatedStorage.Utils.TableUtil)
local ORIGIN = Vector3.new(0, 0, 0)
local module = {}

module.Metrics = {
	EUCLIDEAN = function(a, b)
		return (a - b).Magnitude
	end,
	MANHATTAN = function(a, b)
		local diff = a - b
		return math.abs(diff.X) + math.abs(diff.Y) + math.abs(diff.Z)
	end
}

local memoizedCube = {
	[0] = {ORIGIN}
}

local function getMemoizedCube(n)
	if not memoizedCube[n] then
		local list = TableUtil.shallow(getMemoizedCube(n - 1))
		for x = -n, n do
			for y = -n, n do
				for z = -n, n do
					if math.abs(x) == n or math.abs(y) == n or math.abs(z) == n then
						list[#list + 1] = Vector3.new(x, y, z)
					end
				end
			end
		end
		memoizedCube[n] = list
	end
	return memoizedCube[n]
end

function module.GetCubeNeighbors(n, vec, mult)
	local list = getMemoizedCube(n)
	return TableUtil.map(
		list,
		function(_, v)
			return vec + v * mult
		end
	)
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

local memoizedManhattan = {
	[0] = {ORIGIN}
}

local function getMemoizedManhattan(n)
	if not memoizedManhattan[n] then
		local list = TableUtil.shallow(getMemoizedManhattan(n - 1))
		for x = -n, n do
			for y = -n, n do
				for z = -n, n do
					if module.Metrics.MANHATTAN(Vector3.new(x,y,z), ORIGIN) == n then
						list[#list + 1] = Vector3.new(x, y, z)
					end
				end
			end
		end
		memoizedManhattan[n] = list
	end
	return memoizedManhattan[n]
end

function module.GetManhattanNeighbors(n, vec, mult)
	local list = getMemoizedManhattan(n)
	return TableUtil.map(
		list,
		function(_, v)
			return vec + v * mult
		end
	)
end

function module.SortListByDistTo(list, vec, metric)
	metric = metric or module.Metrics.EUCLIDEAN
	table.sort(
		list,
		function(a, b)
			return metric(a, vec) < metric(b, vec)
		end
	)
end

function module.MarkPoints(points)
	local p = Instance.new("Part")
	p.CanCollide = false
	p.Anchored = true
	p.Size = Vector3.new(.2, .2, .2)
	p.Color = Color3.new(1, 0, 0)
	local partClones =
		TableUtil.map(
		points,
		function(_, pt)
			local cloned = p:Clone()
			cloned.CFrame = CFrame.new(pt)
			cloned.Parent = Workspace
			return cloned
		end
	)
	return function()
		TableUtil.map(
			partClones,
			function(_, part)
				part:Destroy()
			end
		)
	end
end

return module
