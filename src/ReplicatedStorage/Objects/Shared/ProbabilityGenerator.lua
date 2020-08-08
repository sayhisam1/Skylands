--------------------------------
--// ProbabilityGenerator OBJECT \\--
--== Author: sayhisam1		==--
--------------------------------
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BaseObject = require(ReplicatedStorage.Objects.BaseObject)

local ProbabilityGenerator = setmetatable({}, BaseObject)
ProbabilityGenerator.__index = ProbabilityGenerator
ProbabilityGenerator.ClassName = script.Name

--Creates a new ProbabilityGenerator
function ProbabilityGenerator.new(choices)
    local self = setmetatable(BaseObject.new(), ProbabilityGenerator)
    self._choices = {}
    self:AddChoices(choices)
    return self
end

function ProbabilityGenerator:AddChoices(choices)
    for choice, weight in pairs(choices) do
        self._choices[choice] = weight
    end
end

-- Sample n things from the probability generator
function ProbabilityGenerator:Sample(n)
    n = n or 1
    -- get total weight first
    local total_weight = 0
    for _, weight in pairs(self._choices) do
        total_weight = total_weight + weight
    end

    -- create normalized weight list
    local normalized_choices = {}
    for choice, weight in pairs(self._choices) do
        normalized_choices[choice] = weight / total_weight
    end

    -- select the n choices
    local selected = {}
    for i = 1, n do
        local rand = math.random()
        local curr_sum = 0
        for choice, normalized_weight in pairs(normalized_choices) do
            curr_sum = curr_sum + normalized_weight
            if rand <= curr_sum then
                selected[#selected + 1] = choice
                break
            end
        end
    end

    return selected
end

return ProbabilityGenerator
