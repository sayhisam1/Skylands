--[[
	Stack OBJECT
@public
	Stack.New()
	Stack:Pop()
	Stack:Push()
	Stack:IsEmpty()
	Stack:Peek()
--]]
local Stack = {
    left_ptr = 0,
    right_ptr = 0
}

function Stack:New()
    self.__index = self
    local obj = setmetatable({}, Stack)

    obj.left_ptr = 0
    obj.right_ptr = 0

    return obj
end

-- Responsible for popping the first object from the Stack.
-- @return Object returns the object popped, or nil if the Stack is empty.
function Stack:Pop()
    if (self.left_ptr >= self.right_ptr) then
        return nil
    end
    self.right_ptr = self.right_ptr - 1
    local obj = self[self.right_ptr]
    self[self.right_ptr] = nil

    return obj
end

-- Responsible for enStacking the passed object into the Stack.
-- @param Object object The object to enStack. Must be non-nil.
function Stack:Push(object)
    self[self.right_ptr] = object
    self.right_ptr = self.right_ptr + 1
end

-- Responsible for getting the next object to be popped (does not pop)
-- @return Object	The object that will be popped next
function Stack:Peek()
    return self[self.right_ptr - 1]
end

-- Responsible for getting the size of the stack
-- @return int	The size of the stack
function Stack:GetSize()
    return self.right_ptr - self.left_ptr
end

-- Responsible for determining if the Stack is empty.
-- @return bool true if empty, false if not.
function Stack:IsEmpty()
    return self.left_ptr >= self.right_ptr
end

return Stack
