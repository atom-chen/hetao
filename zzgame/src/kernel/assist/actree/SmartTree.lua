-------------------------
-- 动作树
-------------------------
module("smartor",package.seeall)

local ST_XTREE_READY = 1		--已构建
local ST_XTREE_PLAYING = 2		--播放中
local ST_XTREE_FINISHED = 3		--播放完毕
local ST_XTREE_STOPED = 4		--被强制停止

clsSmartTree = class("clsSmartTree")

function clsSmartTree:ctor()
	self.iCurState = ST_XTREE_READY
	self.mRootNode = nil
	self.mXContext = clsSmartContext.new()
	self.tAllNodes = {}
end

function clsSmartTree:dtor()
	self:Stop()
	
	KE_SafeDelete(self.mRootNode)
	self.mRootNode = nil
	self.tAllNodes = {}
	
	KE_SafeDelete(self.mXContext)
	self.mXContext = nil
end

function clsSmartTree:GetContext() 
	return self.mXContext 
end

function clsSmartTree:GetRoot()
	return self.mRootNode
end

function clsSmartTree:SetRoot(oXNode)
	assert(oXNode:IsRootNode())
	assert(not self.mRootNode, "已经设置了根节点")
	self.mRootNode = oXNode
end

function clsSmartTree:IsPlaying()
	return self.iCurState == ST_XTREE_PLAYING
end

---------------------------------------------------------------

function clsSmartTree:Recover()
	if self.iCurState~=ST_XTREE_FINISHED and self.iCurState~=ST_XTREE_STOPED then
		logger.error("没事别乱Recover", self.iCurState)
		return
	end
	self.mRootNode:Recover()
	self.iCurState = ST_XTREE_READY
end

function clsSmartTree:Stop()
	if self:IsPlaying() then
		logger.drama("中断SmartTree")
		self.mRootNode:Stop()
		self.iCurState = ST_XTREE_STOPED
		local cbFinish = self._finishCallback
		self._finishCallback = nil 
		if cbFinish then
			cbFinish(XTREE_FINISH_REASON.BREAKED)
		end
	end
end

function clsSmartTree:Play(finishCallback)
	if self.iCurState == ST_XTREE_PLAYING then 
		logger.drama("已经在播放中")
		return 
	end
	assert(self.iCurState == ST_XTREE_READY, "只能从ST_XTREE_READY切换到ST_XTREE_PLAYING  当前："..self.iCurState)
	self.iCurState = ST_XTREE_PLAYING
	self._finishCallback = finishCallback
	self.mRootNode:Run()
end

function clsSmartTree:OnPlayOver(promise)
	self.iCurState = ST_XTREE_FINISHED
	promise:Done()
	local cbFinish = self._finishCallback
	self._finishCallback = nil 
	if cbFinish then
		cbFinish(XTREE_FINISH_REASON.BREAKED)
	end
end

---------------------------------------------------------------

-- 检测是否是有效的信息列表
-- 1. 检测孤岛，因为无法从根节点走到孤岛点，所以孤岛点是多余信息，而且会造成XTree永远无法播放完毕
-- 2. 检测环，如果存在环会导致死循环（有时候也许故意要循环）
function clsSmartTree:CheckValid(root_node, node_list)
	local all_nodes = {}
	
	--检查是否存在环
	if root_node:HasCircle(all_nodes) then
		return false 
	end
	
	--检查是否存在孤岛
	local cnt1, cnt2 = table.size(all_nodes), table.size(node_list)
	if cnt1 ~= cnt2 then
		local i = 0
		for id, node in pairs(node_list) do
			if not all_nodes[node] then
				i = i + 1
				logger.drama("孤岛"..i..": ", id)
			end
		end
		assert(false, string.format("存在%d个孤岛", cnt2-cnt1))
		return false 
	end
	
	return true
end

function clsSmartTree:BuildByInfo(info_list)
	assert(is_table(info_list))
	assert(not self.mRootNode, "已经构建")
	
	local xCtx = self.mXContext
	local root_node 
	local node_list = {}
	
	-- 创建所有节点
	for idx, xInfo in pairs(info_list) do
		node_list[idx] = smartor.NewUnit(xInfo.cmdName, xInfo.args, xCtx)
		if xInfo.cmdName == "x_root_node" then
			assert(not root_node, "Error: 只能存在一个根节点")
			root_node = node_list[idx]
		end
	end
	
	-- 将节点挂接起来
	for idx, xInfo in pairs(info_list) do
		if xInfo.nextpms then
			node_list[idx]:SetNext(node_list[xInfo.nextpms])
		end
		
		for evtName, childList in pairs(xInfo.connectors) do
			for _, childIdx in ipairs(childList) do
				assert(node_list[childIdx], string.format("节点[%d]不存在，请检查配置：",childIdx))
				node_list[idx]:AddPart(evtName, node_list[childIdx])
			end
		end
	end
	
	if self:CheckValid(root_node, node_list) then
		self.tAllNodes = node_list
		self:SetRoot(root_node)
		self.iCurState = ST_XTREE_READY
		root_node:NextCall(self.OnPlayOver, self):SetName("tree end")
	end
end

function clsSmartTree:SaveData(sPath)
	assert(sPath, "请输入存放路径")
	local node_list = self.tAllNodes
	local map_node_2_idx = {}
	for idx, node in pairs(node_list) do
		map_node_2_idx[node] = idx
	end
	
	--
	local info_list = {}
	
	function walk_all(smtNode)
		-- walk self
		local info = {
			["args"] = smtNode:GetArgInfo() or {},
			["cmdName"] = smtNode:GetNodeType(),
			["connectors"] = {},
			["nextpms"] = nil,
		}
		if smtNode:GetNodeType() ~= "unknown" then
			info_list[ map_node_2_idx[smtNode] ] = info 
		end
		-- walk parts
		if smtNode._subNodes then
			for evtName, partlist in pairs(smtNode._subNodes) do
				for _, part in ipairs(partlist) do
					info.connectors[evtName] = info.connectors[evtName] or {}
					table.insert(info.connectors[evtName], map_node_2_idx[subNode])
					walk_all(part)
				end
			end
		end
		-- walk next
		if smtNode._next then
			info["nextpms"] = map_node_2_idx[smtNode._next]
			walk_all(smtNode._next)
		end
	end
	walk_all(self.mRootNode)
	
	table.save(info_list, sPath)
end
