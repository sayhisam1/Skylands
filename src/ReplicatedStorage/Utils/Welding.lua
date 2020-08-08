local module = {}
function module.weldTogether(a, b, C0)
	if (a and a:IsA("BasePart") and b and b:IsA("BasePart")) then
		local weld = Instance.new("Weld")
		weld.Name = b.Name
		weld.Part0 = a
		weld.Part1 = b
		weld.C0 = C0 or weld.Part0.CFrame:toObjectSpace(weld.Part1.CFrame)
		weld.C1 = CFrame.new(0, 0, 0)
		weld.Parent = a
		return weld
	end
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
		weld.Name = b.Name
		weld.Part0 = a
		weld.Part1 = b
		weld.C0 = C0 or weld.Part0.CFrame:toObjectSpace(weld.Part1.CFrame)
		weld.C1 = CFrame.new(0, 0, 0)
		weld.Parent = a
		return weld
	end
end

function module.addAttachments(a, b)
	if (a and a:IsA("BasePart") and b and b:IsA("BasePart")) then
		local attachment_1 = Instance.new("Attachment")
		attachment_1.Parent = a
		local attachment_2 = Instance.new("Attachment")
		attachment_2.Parent = b
		return attachment_1, attachment_2
	end
end
return module
