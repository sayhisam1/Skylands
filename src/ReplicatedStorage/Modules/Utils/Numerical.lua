local module = {}

-- Implements Runge-Kutta 4 stage ODE solver
-- @param y_n 	-- initial condition at timestep n 
-- @param dy_dt -- function that returns transformation at timestep t (from y_n), given initial condition 
-- @param h		-- step size of time
function module:RK4(y_n, dy_dt, h)
	local k1 = h * dy_dt(0, y_n)
	local k2 = h * dy_dt(h/2, y_n + k1/2)
	local k3 = h * dy_dt(h/2, y_n + k2/2)
	local k4 = h * dy_dt(h, y_n + k3)
	return y_n + 1/6 * (k1 + 2*k2 + 2*k3 + k4)
end

return module
