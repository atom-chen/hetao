-------------------------
-- 队列
-------------------------
clsQueue = class("clsQueue")

function clsQueue:ctor()
	self.iHead = 0
	self.iTail = 0
	self.tElementList = {}
end

function clsQueue:dtor()
	self.tElementList = {}
	self.iHead = 0
	self.iTail = 0
end

function clsQueue:Push(obj)
	self.iTail = self.iTail + 1
	self.tElementList[self.iTail] = obj
end

function clsQueue:Pop()
	if self.iHead == self.iTail then return end
	self.iHead = self.iHead + 1
	local Element = self.tElementList[self.iHead]
	self.tElementList[self.iHead] = nil
	return Element
end

function clsQueue:IsEmpty()
	return self.iHead==self.iTail
end

function clsQueue:GetSize()
	return self.iTail-self.iHead
end

function clsQueue:GetFirstElement()
	return self.tElementList[self.iHead+1]
end

function clsQueue:GetLastElement()
	return self.tElementList[self.iTail]
end
