--------------------------------
--// ProbabilityDistribution OBJECT \\--
--== Author: sayhisam1		==--
--------------------------------

local ProbabilityDistribution = {}
ProbabilityDistribution.__index = ProbabilityDistribution
ProbabilityDistribution.ClassName = script.Name

--Creates a new ProbabilityDistribution
function ProbabilityDistribution.new(samples)
    local self = setmetatable({}, ProbabilityDistribution)
    self._samples = {}
    self:AddSamples(samples)
    return self
end

function ProbabilityDistribution:AddSamples(samples)
    for sample, weight in pairs(samples) do
        self._samples[sample] = weight
    end
    self._normalizedSamples = self:GetNormalizedProbabilities()
end

-- Sample n things from the probability generator
function ProbabilityDistribution:Sample(n)
    n = n or 1

    -- select the n samples
    local selected = {}
    for i = 1, n do
        local rand = math.random()
        local curr_sum = 0
        for sample, normalized_weight in pairs(self._normalizedSamples) do
            curr_sum = curr_sum + normalized_weight
            if rand <= curr_sum then
                selected[#selected + 1] = sample
                break
            end
        end
    end

    return selected
end

function ProbabilityDistribution:GetSampleSpace()
    return self.TableUtil.keys(self._samples)
end

function ProbabilityDistribution:GetNormalizedProbabilities()
    -- get total weight first
    local total_weight = 0
    for _, weight in pairs(self._samples) do
        total_weight = total_weight + weight
    end

    -- create normalized weight list
    local normalized_samples = {}
    for sample, weight in pairs(self._samples) do
        normalized_samples[sample] = weight / total_weight
    end
    self._normalizedSamples = normalized_samples
    return normalized_samples
end

return ProbabilityDistribution
