-------------------------
-- 行为树数据
-------------------------
module("ai",package.seeall)

clsBlackBoard = class("clsBlackBoard", clsCoreObject)

function clsBlackBoard:ctor(theOwner)
	clsCoreObject.ctor(self)
	assert(theOwner)
	self.mOwner = theOwner		--黑板拥有者
	self.tRunningTree = new_weak_table("k")		--所有处于RUNNING状态的行为树
	self.tRunningNodes = new_weak_table("k")	--所有处于RUNNING状态的节点
	self._callback_info = {}	--行为树执行完成回调
	self.tInterupting = {}		--标记正在执行中断的行为树
end

function clsBlackBoard:dtor()
	self.mOwner = nil 
	self.tRunningNodes = nil
	self.tRunningTree = nil
	self._callback_info = nil
end

function clsBlackBoard:GetOwner() 
	return self.mOwner
end

------------------------------------------------------------------------

-- 行为树开始执行时，标记到BlackBoard
function clsBlackBoard:TellBTBegin(btTree, Callback)
	assert(not btTree:IsRunning(self.mOwner))
	logger.ai("行为树开始", self.mOwner:GetUid(), btTree.__cname)
	self.tRunningTree[btTree] = BTSTATE.RUNNING
	self._callback_info[btTree] = Callback
end 

-- 行为树结束的最终接口
function clsBlackBoard:tell_bt_result(btTree, result)
	assert(not self:HasRunningNodeOfTree(btTree), "还有执行中的节点")
	if self._callback_info[btTree] then 
		self._callback_info[btTree](result) 
		self._callback_info[btTree] = nil 
	end
	self.tRunningTree[btTree] = result
	logger.ai("行为树结束", self.mOwner:GetUid(), btTree.__cname, result)
end

-- 行为树被中断时，标记到BlackBoard
function clsBlackBoard:TellBTInterrupt(btTree)
	self:tell_bt_result(btTree, BTSTATE.FAIL)
end

-- 行为树执行完成时，标记到BlackBoard
function clsBlackBoard:TellBTFinish(btTree, result)
	self:tell_bt_result(btTree, result)
end

-- 节点开始执行前，标记到BlackBoard
function clsBlackBoard:AddRunningNode(RunningNode)
	assert(not self:IsInterrupting(RunningNode:GetBTTree()), "中断的时候不可以加节点哦")
	self.tRunningNodes[RunningNode] = BTSTATE.RUNNING
end

-- 节点执行完成后，标记到BlackBoard
function clsBlackBoard:DelRunningNode(RunningNode, result)
	assert(self.tRunningNodes[RunningNode] == BTSTATE.RUNNING, self.mOwner:GetUid()..":"..RunningNode.__cname)
	assert(result==BTSTATE.SUCC or result==BTSTATE.FAIL)
	self.tRunningNodes[RunningNode] = result
end

-- 
function clsBlackBoard:MarkInterupting(btTree, flag)
	self.tInterupting[btTree] = flag
end

--
function clsBlackBoard:IsInterrupting(btTree)
	return self.tInterupting[btTree] == true
end

------------------------------------------------------------------------

function clsBlackBoard:HasRunningNode(btNode)
	return self.tRunningNodes[btNode] == BTSTATE.RUNNING
end

function clsBlackBoard:HasRunningTree(btTree)
	return self.tRunningTree[btTree] == BTSTATE.RUNNING
end

function clsBlackBoard:HasRunningNodeOfTree(btTree)
	for node, state in pairs(self.tRunningNodes) do
		if state==BTSTATE.RUNNING and node:GetBTTree() == btTree then
			return true
		end
	end
	return false
end

function clsBlackBoard:GetRunningNodesOfTree(btTree)
	local running_nodes
	for node, state in pairs(self.tRunningNodes) do
		if state==BTSTATE.RUNNING and node:GetBTTree() == btTree then
			running_nodes = running_nodes or {}
			table.insert(running_nodes, node)
		end
	end
	return running_nodes
end
