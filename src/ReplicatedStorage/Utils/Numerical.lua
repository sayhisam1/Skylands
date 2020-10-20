local module = {}
local PI = 3.14
local PHI = 1.618

-- Implements Runge-Kutta 4 stage ODE solver
-- @param y_n 	-- initial condition at timestep n
-- @param dy_dt -- function that returns transformation at timestep t (from y_n), given initial condition
-- @param h		-- step size of time
function module.RK4(y_n, dy_dt, h)
	local k1 = h * dy_dt(0, y_n)
	local k2 = h * dy_dt(h / 2, y_n + k1 / 2)
	local k3 = h * dy_dt(h / 2, y_n + k2 / 2)
	local k4 = h * dy_dt(h, y_n + k3)
	return y_n + 1 / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
end

-- Implements Vogel model for fibonacci spiral
-- @param n		-- index number
-- @param c		-- scale factor
function module.fibonacciSpiral(n, c)
	local theta = 6.28 * n / (PHI * PHI)
	local r = c * math.sqrt(n)
	return theta, r
end

-- converts spherical coordinates given by theta, phi into cartesian
function module.sphericalToCartesian(theta, phi)
	local x = math.sin(phi) * math.cos(theta)
	local y = math.sin(phi) * math.sin(theta)
	local z = math.cos(phi)
	return x, y, z
end
-- Returns a random point uniformly sampled from the unit sphere
-- see: https://mathworld.wolfram.com/SpherePointPicking.html
function module.randSpherical()
	local u,
		v = math.random(), math.random()
	local theta = 2 * PI * u
	local phi = math.acos(2 * v - 1)

	return Vector3.new(module.sphericalToCartesian(theta, phi))
end

-- returns a parabola generator from start -> end, given acceleration
function module.ballisticMotion(s, e, accel)
	local d = e - s
	-- d(t) = v_i*t + 1/2*a*t^2
	-- need to find vi s.t. d(1) + s = e
	local v_i = -.5 * accel + d
	return function(t)
		return s + v_i * t + .5 * accel * t ^ 2
	end
end

return module
