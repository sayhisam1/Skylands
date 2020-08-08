local module = {}
local datadump_table
local MAX_STACK = 5
function module.dd(data, original_tabs, curr_stack, seen)
	curr_stack = curr_stack or 0
	seen = seen or {}
	if (curr_stack > MAX_STACK) then
		return "<stack limit reached>"
	end
	original_tabs = original_tabs or ""
	local stringRet = ""
	if (type(data) == "table") then
		stringRet = original_tabs .. "{\n"
		local tabs = original_tabs .. "  "
		seen[data] = (seen[data] or 0) + 1
		for i, v in pairs(data) do
			local key = (type(i) ~= "function" and i) or "TYPE:FUNC"
			stringRet =
				stringRet .. tabs .. tostring(key) .. "  :  " .. datadump_table[type(v)](v, original_tabs, curr_stack, seen) .. "\n"
		end
		seen[data] = seen[data] - 1
		stringRet = stringRet .. original_tabs .. "}\n"
		return stringRet
	else
		return datadump_table[type(data)](data)
	end
end

datadump_table = {}
datadump_table["nil"] = function()
	return ("nil")
end
datadump_table["boolean"] = function(val)
	return (tostring(val))
end
datadump_table["number"] = function(val)
	return tostring(val)
end
datadump_table["string"] = function(val)
	return val
end
datadump_table["userdata"] = function(val)
	return tostring(val)
end
datadump_table["function"] = function(val)
	return tostring(val)
end
datadump_table["thread"] = function()
	return "thread"
end
datadump_table["table"] = function(tbl, tabs, curr_stack, seen)
	if ((seen[tbl] or 0) > 0) then
		return "<cycle detected!>"
	end
	return module.dd(tbl, tabs .. "  ", curr_stack + 1, seen)
end

function module.typeValid(data)
	return type(data) ~= "userdata", typeof(data)
end

function module.scanValidity(tbl, passed, path)
	if type(tbl) ~= "table" then
		return module.scanValidity({input = tbl}, {}, {})
	end
	passed, path = passed or {}, path or {"input"}
	passed[tbl] = true
	local tblType
	do
		local key, value = next(tbl)
		if type(key) == "number" then
			tblType = "Array"
		else
			tblType = "Dictionary"
		end
	end
	local last = 0
	for key, value in next, tbl do
		path[#path + 1] = tostring(key)
		if type(key) == "number" then
			if tblType == "Dictionary" then
				return false, path, "Mixed Array/Dictionary"
			elseif key % 1 ~= 0 then -- if not an integer
				return false, path, "Non-integer index"
			elseif key == math.huge or key == -math.huge then
				return false, path, "(-)Infinity index"
			end
		elseif type(key) ~= "string" then
			return false, path, "Non-string key", typeof(key)
		elseif tblType == "Array" then
			return false, path, "Mixed Array/Dictionary"
		end
		if tblType == "Array" then
			if last ~= key - 1 then
				return false, path, "Array with non-sequential indexes"
			end
			last = key
		end
		local isTypeValid, valueType = module.typeValid(value)
		if not isTypeValid then
			return false, path, "Invalid type", valueType
		end
		if type(value) == "table" then
			if passed[value] then
				return false, path, "Cyclic"
			end
			local isValid, keyPath, reason, extra = module.scanValidity(value, passed, path)
			if not isValid then
				return isValid, keyPath, reason, extra
			end
		end
		path[#path] = nil
	end
	passed[tbl] = nil
	return true
end
function module.getStringPath(path)
	return table.concat(path, ".")
end
return module
