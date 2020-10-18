-- Money Functions Library

--[[
NOTICE
Copyright (c) 2019 Andrew Bereza
Provided for public use in educational, recreational or commercial purposes under the Apache 2 License.
Please include this copyright & permission notice in all copies or substantial portions of Miner's Haven source code
]]
local MoneyLib = {}

MoneyLib.Suffixes = {
	"k",
	"M",
	"B",
	"T",
	"qd",
	"Qn",
	"sx",
	"Sp",
	"O",
	"N",
	"de",
	"Ud",
	"DD",
	"tdD",
	"qdD",
	"QnD",
	"sxD",
	"SpD",
	"OcD",
	"NvD",
	"Vgn",
	"UVg",
	"DVg",
	"TVg",
	"qtV",
	"QnV",
	"SeV",
	"SPG",
	"OVG",
	"NVG",
	"TGN",
	"UTG",
	"DTG",
	"tsTG",
	"qtTG",
	"QnTG",
	"ssTG",
	"SpTG",
	"OcTG",
	"NoTG",
	"QdDR",
	"uQDR",
	"dQDR",
	"tQDR",
	"qdQDR",
	"QnQDR",
	"sxQDR",
	"SpQDR",
	"OQDDr",
	"NQDDr",
	"qQGNT",
	"uQGNT",
	"dQGNT",
	"tQGNT",
	"qdQGNT",
	"QnQGNT",
	"sxQGNT",
	"SpQGNT",
	"OQQGNT",
	"NQQGNT",
	"SXGNTL"
}
--                                                  																																															^NEW     ^ 10e123
-- 2/3 was TOO HIGH

-- 2/3.5
-- 4/7

-- 2/4 TOO LOW
-- 2/5 is TOO LOW

return function(input)
	if input == math.huge then
		return "∞"
	end
	local Negative = input < 0
	input = math.abs(input)

	local Paired = false
	for i, v in pairs(MoneyLib.Suffixes) do
		if not (input >= 10 ^ (3 * i)) then
			input = input / 10 ^ (3 * (i - 1))
			local isComplex = (string.find(tostring(input), ".") and string.sub(tostring(input), 4, 4) ~= ".")
			input = string.sub(tostring(input), 1, (isComplex and 4) or 3) .. (MoneyLib.Suffixes[i - 1] or "")
			Paired = true
			break
		end
	end
	if not Paired then
		local Rounded = math.floor(input)
		input = tostring(Rounded)
	end

	if Negative then
		return "-" .. input
	end
	return input
end
