--[[
	QUEUE OBJECT
@public
	Queue.New()
	Queue:Dequeue()
	Queue:Enqueue(Object object)
	Queue:IsEmpty()
	Queue:Peek()
	Queue:GetSize()
--]]
local Queue = {
    left_ptr = 0,
    right_ptr = 0
}

function Queue:New()
    self.__index = self
    local obj = setmetatable({}, self)

    obj.left_ptr = 0
    obj.right_ptr = 0

    return obj
end

-- Responsible for dequeuing the first object from the queue.
-- @return Object returns the object dequeued, or nil if the queue is empty.
function Queue:Dequeue()
    if (self.left_ptr >= self.right_ptr) then
        return nil
    end
    local obj = self[self.left_ptr]
    self[self.left_ptr] = nil
    self.left_ptr = self.left_ptr + 1
    return obj
end

-- Responsible for enqueueing the passed object into the queue.
-- @param Object object The object to enqueue. Must be non-nil.
function Queue:Enqueue(object)
    self[self.right_ptr] = object
    self.right_ptr = self.right_ptr + 1
end

-- Responsible for getting the next object to be dequeued (does not dequeue)
-- @return Object	The object that will be dequeued next
function Queue:Peek()
    return self[self.left_ptr]
end

-- Responsible for getting the size of the queue
-- @return int	The size of the queue
function Queue:GetSize()
    return self.right_ptr - self.left_ptr
end
-- Responsible for determining if the queue is empty.
-- @return bool true if empty, false if not.
function Queue:IsEmpty()
    return self.left_ptr >= self.right_ptr
end

return Queue
