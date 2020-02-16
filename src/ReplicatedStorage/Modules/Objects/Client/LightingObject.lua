local Lighting = game:GetService("Lighting")
local lightingAttributes = {
    "Brightness",
    "Ambient",
    "FogColor",
    "FogEnd",
    "FogStart",
    "ExposureCompensation"
}

local module = {}

function module:AddValue(value_name, val)
    self["Values"][value_name][#self["Values"][value_name] + 1] = val
end

function module:CalculateValues()
    for i, v in pairs(self.Values) do
        if #v > 0 then
            if i == "Ambient" or i == "FogColor" then
                local r, g, b = 0, 0, 0
                for j, k in pairs(v) do
                    r = r + k.r
                    g = g + k.g
                    b = b + k.b
                end
                r = r / #v
                g = g / #v
                b = b / #v
                self.Calculated[i] = Color3.new(r, g, b)
            else
                local val = 0

                for j, k in pairs(v) do
                    val = val + k
                end
                val = val / #v
                self.Calculated[i] = val
            end
        end
    end
end

function module:ApplyValues()
    for i, v in pairs(lightingAttributes) do
        if self.Calculated[v] then
            Lighting[v] = self.Calculated[v]
        end
    end
end

function module:New()
    self.__index = self
    local obj = setmetatable({}, self)
    obj["Values"] = {}
    obj.Calculated = {}
    for i, v in pairs(lightingAttributes) do
        obj["Values"][v] = {}
    end
    return obj
end

return module
