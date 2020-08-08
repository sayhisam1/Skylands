--Tool object is the main controller for tools
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CFrameUtil = {}

function CFrameUtil.MoveRelativeCFrame(root_part, parts, cframe)
	local cframes = {}
	for _,v in pairs(parts) do
		if v:IsA("BasePart") then
			cframes[v] = root_part.CFrame:ToObjectSpace(v.CFrame)
		elseif v:IsA("Model") then
			cframes[v] = root_part.CFrame:ToObjectSpace(v.PrimaryPart.CFrame)
		end
	end

	root_part.CFrame = cframe
	for _,v in pairs(parts) do
		if v:IsA("BasePart") then
			v.CFrame = root_part.CFrame:ToWorldSpace(cframes[v])
		elseif v:IsA("Model") then
			v:SetPrimaryPartCFrame(root_part.CFrame:ToWorldSpace(cframes[v]))
		end
	end

end


function CFrameUtil.AutoSetPrimaryPart(model)
	print("AutoSet", model)
	local orientation, size = model:GetBoundingBox()
	local center_pos = orientation.Position
	local closest = model:FindFirstChildWhichIsA("BasePart", true)
	for _,v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			if (v.Position - center_pos).Magnitude < (closest.Position - center_pos).Magnitude then
				closest = v
			end
		end	
	end
	print("Setting", model, "PrimaryPart to", closest)
	model.PrimaryPart = closest
	return model
end

return CFrameUtil
