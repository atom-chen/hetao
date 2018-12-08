-------------------------
-- 行为树框架
-- 具体实现要继承自 clsDecoratorNode clsConditionNode clsActionNode clsImpulseNode
-------------------------
module("ai",package.seeall)

local function walkBtNode(btNode, theOwner)
	if btNode:IsRunning(theOwner) then return true end
	if btNode.mLeftNode then
		if walkBtNode(btNode.mLeftNode, theOwner) then return true end
	end
	if btNode.mRightNode then
		if walkBtNode(btNode.mRightNode, theOwner) then return true end
	end
	return false
end

-- 节点基类
clsBehaviorNodeBase = class("clsBehaviorNodeBase")

function clsBehaviorNodeBase:ctor()
	self.mLeftNode = nil
	self.mRightNode = nil
	self.mParentNode = nil
	self._parallel = nil
	self._btTree = nil
end

function clsBehaviorNodeBase:dtor()
	self.mParentNode = nil 
	if self.mLeftNode then KE_SafeDelete(self.mLeftNode) self.mLeftNode = nil end
	if self.mRightNode then KE_SafeDelete(self.mRightNode) self.mRightNode = nil end
end

function clsBehaviorNodeBase:Proc(theOwner)
	assert(false, "must override this method")
end

-- 执行本节点
--@return if    BTSTATE.SUCC: 成功
--@return if    BTSTATE.FAIL: 失败
--@return if    BTSTATE.RUNNING: 执行中（需要处理一段时间才知道成功还是失败）
function clsBehaviorNodeBase:Execute(theOwner)
	if theOwner:GetBlackBoard():IsInterrupting(self:GetBTTree()) then return BTSTATE.FAIL end
	if theOwner:GetBlackBoard():HasRunningNode(self) then return BTSTATE.RUNNING end
	-- before deal
	theOwner:GetBlackBoard():AddRunningNode(self)
	-- dealing
	local result = self:Proc(theOwner)
	assert(IsValidBtNodeState(result), self.__cname)
	
	if result == BTSTATE.RUNNING then
		return BTSTATE.RUNNING
	end
	-- deal over 
	return self:OnDealOver(theOwner, result)
end

-- 执行完成后调用
function clsBehaviorNodeBase:OnDealOver(theOwner, result)
	assert(result==BTSTATE.SUCC or result==BTSTATE.FAIL)
	theOwner:GetBlackBoard():DelRunningNode(self, result)
	
	logger.ai("----", self.__cname, result)
	if theOwner:GetBlackBoard():IsInterrupting(self:GetBTTree()) then return BTSTATE.FAIL end
	
	-- 成立则往右走，不成立则往左走
	if result == BTSTATE.SUCC then
		if self.mRightNode then 
			return self.mRightNode:Execute(theOwner) 
		end
	elseif result == BTSTATE.FAIL then
		if self.mLeftNode then 
			return self.mLeftNode:Execute(theOwner) 
		end
	end
	
	-- 如果本节点挂在并行节点下，检查并行节点的返回值
	local myParallel = self:GetMyParallel()
	if myParallel then
		local tmpResult = myParallel:CheckResult(theOwner)
		if tmpResult == BTSTATE.RUNNING then
			return BTSTATE.RUNNING
		else 
			return myParallel.OnDealOver(theOwner, tmpResult)
		end
	end
	
	-- 没有孩子节点了，表明整棵树已经执行完成
	theOwner:GetBlackBoard():TellBTFinish(self:GetBTTree(), result)
	
	return result
end

function clsBehaviorNodeBase:IsRunning(theOwner)
	return theOwner:GetBlackBoard():HasRunningNode(self)
end

function clsBehaviorNodeBase:OnInterrupt(theOwner)

end

function clsBehaviorNodeBase:Interrupt(theOwner)
	self:OnInterrupt(theOwner)
	theOwner:GetBlackBoard():DelRunningNode(self, BTSTATE.FAIL)
end

function clsBehaviorNodeBase:SetRightNode(rNode)
	assert(rNode~=self and not self.mRightNode)
	self.mRightNode = rNode
	rNode.mParentNode = self
	rNode._parallel = self._parallel
end

function clsBehaviorNodeBase:SetLeftNode(lNode)
	assert(lNode~=self and not self.mLeftNode)
	self.mLeftNode = lNode
	lNode.mParentNode = self
	lNode._parallel = self._parallel
end

function clsBehaviorNodeBase:GetRoot()
	if self.mParentNode then
		return self.mParentNode:GetRoot()
	else
		return self
	end
end

function clsBehaviorNodeBase:GetMyParallel()
	if self._parallel then 
		return self._parallel 
	end
	if self.mParentNode then
		return self.mParentNode:GetMyParallel()
	else
		return nil
	end
end

function clsBehaviorNodeBase:GetBTTree()
	if self._btTree then return self._btTree end
	self._btTree = self:GetRoot()._btTree
	return self._btTree
end

function clsBehaviorNodeBase:SetBTTree(btTree)
	assert(not self._btTree, "已经设置过_btTree")
	self._btTree = btTree
end


--复合节点基类，不能为叶子节点
local clsICompositeNode = class("clsICompositeNode", clsBehaviorNodeBase)

function clsICompositeNode:ctor(btNodeList)
	clsBehaviorNodeBase.ctor(self)
	self.tChildList = btNodeList or {}
end

function clsICompositeNode:dtor()
	
end

function clsICompositeNode:AddElement(btNode)
	table.insert(self.tChildList, btNode)
end


-- 并行节点
clsParallelNode = class("clsParallelNode", clsBehaviorNodeBase)

function clsParallelNode:ctor()
	clsBehaviorNodeBase.ctor(self)
	self.tChildList = {}
end

function clsParallelNode:AddPart(btNode)
	table.insert(self.tChildList, btNode)
	btNode._parallel = self
end

--@override
function clsParallelNode:Execute(theOwner)
	if theOwner:GetBlackBoard():IsInterrupting(self:GetBTTree()) then return BTSTATE.FAIL end
	if theOwner:GetBlackBoard():HasRunningNode(self) then return BTSTATE.RUNNING end
	-- before deal
	theOwner:GetBlackBoard():AddRunningNode(self)
	for _, btNode in ipairs(self.tChildList) do
		theOwner:GetBlackBoard():AddRunningNode(btNode)
	end
	-- dealing
	for _, btNode in ipairs(self.tChildList) do
		btNode:Execute(theOwner)
	end
	return self:CheckResult(theOwner)
end

function clsParallelNode:Proc(theOwner)
	assert(false)
end

function clsParallelNode:CheckResult(theOwner)
	local result = BTSTATE.SUCC
	for _, btNode in ipairs(self.tChildList) do
		if walkBtNode(btNode, theOwner) then
			result = BTSTATE.RUNNING
			break;
		end
	end
	return result
end

-------------------------------------------------------------------------

-- 复合节点：条件与
clsAndCompositeNode = class("clsAndCompositeNode", clsICompositeNode)

function clsAndCompositeNode:ctor(btNodeList)
	clsICompositeNode.ctor(self,btNodeList)
end

function clsAndCompositeNode.dtor()

end

function clsAndCompositeNode:Proc(theOwner)
	for _, child in ipairs(self.tChildList) do
		if child:Proc(theOwner) == BTSTATE.FAIL then
			return BTSTATE.FAIL
		end
	end
	return BTSTATE.SUCC
end

-- 复合节点：条件或
clsOrCompositeNode = class("clsOrCompositeNode", clsICompositeNode)

function clsOrCompositeNode:ctor(btNodeList)
	clsICompositeNode.ctor(self,btNodeList)
end

function clsOrCompositeNode.dtor()

end

function clsOrCompositeNode:Proc(theOwner)
	for _, child in ipairs(self.tChildList) do
		if child:Proc(theOwner) == BTSTATE.SUCC then
			return BTSTATE.SUCC
		end
	end
	return BTSTATE.FAIL
end

--------------------------------------------------------------------

-- 装饰结点
clsDecoratorNode = class("clsDecoratorNode", clsBehaviorNodeBase)

function clsDecoratorNode:ctor(decTarget)
	clsBehaviorNodeBase.ctor(self)
	self:Proxy(decTarget)
end

function clsDecoratorNode:Proc(theOwner)
	return self._decorateTarget:Proc(theOwner)
end

function clsDecoratorNode:Proxy(decTarget)
	assert(decTarget)
	self._decorateTarget = decTarget
end

-- 神经冲动结点
clsImpulseNode = class("clsImpulseNode", clsBehaviorNodeBase)

function clsImpulseNode:ctor()
	clsBehaviorNodeBase.ctor(self)
end

-- 条件节点
clsConditionNode = class("clsConditionNode", clsBehaviorNodeBase)

function clsConditionNode:ctor()
	clsBehaviorNodeBase.ctor(self)
end

-- 动作节点
clsActionNode = class("clsActionNode", clsBehaviorNodeBase)

function clsActionNode:ctor()
	clsBehaviorNodeBase.ctor(self)
end
