--[[
	Stack OBJECT
@public
	Stack.new()
	Stack:Pop()
	Stack:Push()
	Stack:IsEmpty()
	Stack:Peek()
--]]
local Stack = {
    left_ptr = 0,
    right_ptr = 0
}

Stack.__index = Stack
Stack.ClassName = script.Name

function Stack.new()
    local self = setmetatable({}, Stack)

    self.left_ptr = 0
    self.right_ptr = 0

    return self
end

function Stack:Destroy()
    for i, v in pairs(self) do
        self[i] = nil
    end
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
