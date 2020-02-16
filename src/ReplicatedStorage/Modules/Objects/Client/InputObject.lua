--[[
	InputObject class
	Allows for a single input to work with multiple keys at once (ie: press both Shift and X to do something)
	
--]]
--REQUIRED CLASSES--
local InputObject = {
    InputData = {},
    OverridesGuiGrab = false
}

--CONSTRUCTOR--

function InputObject:New(input, allowed_state)
    self.__index = self
    local obj = setmetatable({}, self)

    obj.InputData = {}
    obj:AddInput(input, allowed_state)

    return obj
end

function InputObject:AddInput(input, allowed_state)
    allowed_state = allowed_state or Enum.UserInputState.Begin
    self.InputData[#self.InputData + 1] = {
        input,
        allowed_state
    }
end

function InputObject:GetInputs()
    return self.InputData
end

return InputObject
