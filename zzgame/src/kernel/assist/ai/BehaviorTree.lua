-------------------------
-- 行为树基类
-------------------------
module("ai",package.seeall)

clsBehaviorTree = class("clsBehaviorTree")

function clsBehaviorTree:ctor()
	self.mRootNode = nil
end

function clsBehaviorTree:dtor()
	assert(false)
end

-- 设置根节点
function clsBehaviorTree:SetRootNode(btNode)
	assert(not self.mRootNode, "只能有一个根节点")
	self.mRootNode = btNode
	btNode:SetBTTree(self)
end

-- 是否在执行中
function clsBehaviorTree:IsRunning(theOwner)
	return theOwner:GetBlackBoard():HasRunningTree(self)
end

-- 执行
function clsBehaviorTree:Execute(theOwner, Callback)
	if self:IsRunning(theOwner) then
		--logger.ai("该行为树已经在执行中", theOwner:GetUid(),self.__cname)
		return BTSTATE.RUNNING
	end
	theOwner:GetBlackBoard():TellBTBegin(self, Callback)
	return self.mRootNode:Execute(theOwner)
end

-- 中断执行
function clsBehaviorTree:Interrupt(theOwner)
	local running_nodes = theOwner:GetBlackBoard():GetRunningNodesOfTree(self)
	if running_nodes then
		theOwner:GetBlackBoard():MarkInterupting(self, true)
		for _, DealNode in ipairs(running_nodes) do 
			DealNode:Interrupt(theOwner)
		end
		theOwner:GetBlackBoard():MarkInterupting(self, false)
		theOwner:GetBlackBoard():TellBTInterrupt(self)
	end
end
