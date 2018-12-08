-------------------------
-- 栈
-------------------------
clsStack = class("clsStack")

function clsStack:ctor()
	self.tElementList = {}
end

function clsStack:dtor()
	self.tElementList = {}
end

function clsStack:Push(obj)
	self.tElementList[#self.tElementList+1] = obj
end

function clsStack:Pop()
	return table.remove(self.tElementList)
end

function clsStack:IsEmpty()
	return #self.tElementList > 0
end

function clsStack:GetSize()
	return #self.tElementList
end
