local module = {}
function module.weldTogether(a, b, C0)
	if (a:IsA("BasePart") and b:IsA("BasePart")) then
		local weld = Instance.new("Weld")
		weld.Name = b.Name .. "Weld"
		weld.Part0 = a
		weld.Part1 = b
		weld.C0 = C0 or weld.Part0.CFrame:toObjectSpace(weld.Part1.CFrame)
		weld.C1 = CFrame.new(0, 0, 0)
		weld.Parent = a
		return weld
	end
end

function module.makeWelds(model, weldRootPart, callback)
	local welds = {}
	local parts = {}
	weldRootPart = weldRootPart or model.PrimaryPart
	parts[#parts + 1] = weldRootPart
	for i, v in pairs(model:GetDescendants()) do
		if (v:IsA("BasePart") and v ~= weldRootPart) then
			welds[#welds + 1] = module.weldTogether(weldRootPart, v)
			parts[#parts + 1] = v
		end
	end
	return parts, welds
end
function module.breakWelds(model)
	for i, v in pairs(model:GetDescendants()) do
		if (v:IsA("JointInstance")) then
			v:Destroy()
		end
	end
end

function module.motor6dParts(a, b, C0)
	if (a:IsA("BasePart") and b:IsA("BasePart")) then
		local weld = Instance.new("Motor6D")
		weld.Name = b.Name .. "Weld"
		weld.Part0 = a
		weld.Part1 = b
		weld.C0 = C0 or weld.Part0.CFrame:toObjectSpace(weld.Part1.CFrame)
		weld.C1 = CFrame.new(0, 0, 0)
		weld.Parent = a
		return weld
	end
end
function module.makeMotor6d(model, root_part, callback)
	local welds = {}
	local parts = {}
	local weldRootPart = root_part or model.PrimaryPart
	parts[#parts + 1] = weldRootPart
	for i, v in pairs(model:GetDescendants()) do
		if (v:IsA("BasePart") and v ~= weldRootPart) then
			welds[#welds + 1] = module.motor6dParts(weldRootPart, v)
			parts[#parts + 1] = v
		end
	end
	return parts, welds
end
return module
