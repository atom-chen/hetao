-------------------------
-- 串行并行播放管理
-------------------------
module("smartor",package.seeall)

local AUTO_ID = 0
local STATE_READY = 1
local STATE_RUNNING = 2
local STATE_DONE = 3
local STATE_STOPED = 4

local is_empty_tbl = table.is_empty

clsPromise = class("clsPromise", clsCoreObject)

function clsPromise:ctor(argInfo, Ctx)
	clsCoreObject.ctor(self)
--	assert(argInfo, "Error：没设置播放参数")
--	assert(Ctx, "Error: 没有设置上下文")
	
	AUTO_ID = AUTO_ID + 1
	self._node_type = AUTO_ID
	
	self._bAutoClean = false		--是否自动清理
	self._context = Ctx				--环境
	self._argInfo = argInfo			--节点参数
	self._procCaller = nil			--处理函数
	self._stopCaller = nil			--停止函数
	self._subNodes = {}				--子节点列表
	self._belongTo = nil			--父节点
	self._next = nil				--下一个节点
	
	self._cur_state = STATE_READY	--当前状态
	self._playOver = false
	self._trigger_points = {}		--事件点通过计时器触发
	
	if Ctx and argInfo then
		Ctx:MarkAtomId(argInfo.atom_id)
	end
end

function clsPromise:dtor()
	self:Stop()
end

function clsPromise:SetName(name)
	self._node_type = name
	return self 
end 

function clsPromise:GetContext()
	return self._context
end
function clsPromise:GetArgInfo()
	return self._argInfo
end
function clsPromise:GetNodeType() 
	return self._node_type 
end
function clsPromise:IsRootNode() 
	return self._node_type == "x_root_node" 
end

function clsPromise:Clean()
	self._context = nil
	self._argInfo = nil
	self._procCaller = nil
	self._stopCaller = nil
	self._subNodes = nil
end

function clsPromise:SetProcFunc(Func, thisObj, ...)
	assert(self._cur_state==STATE_READY)
	self._procCaller = clsCaller.new(Func, thisObj, ...)
end

function clsPromise:SetStopFunc(Func, thisObj, ...)
	assert(self._cur_state==STATE_READY)
	self._stopCaller = clsCaller.new(Func, thisObj, ...)
end

function clsPromise:AddPart(evtPoint, oNode)
	assert(evtPoint>=0)
	assert(self._cur_state == STATE_READY, "不可在非准备状态下挂接子节点")
	oNode._belongTo = self
	self._subNodes[evtPoint] = self._subNodes[evtPoint] or {}
	table.insert(self._subNodes[evtPoint], oNode)
end

function clsPromise:SetNext(nextNode)
	local last = self:GetLast()
	assert(not last._next, "已经设置过next节点")
	nextNode._belongTo = last._belongTo
	last._next = nextNode
	return nextNode
end

function clsPromise:PartCall(evtPoint, func, thisObj, ...)
	local partNode = clsPromise.new()
	partNode:SetProcFunc(func, thisObj, ...)
	self:AddPart(evtPoint, partNode)
	return partNode
end

function clsPromise:NextCall(func, thisObj, ...)
	local nextNode = clsPromise.new()
	nextNode:SetProcFunc(func, thisObj, ...)
	self:SetNext(nextNode)
	return nextNode
end

function clsPromise:GetLast()
	local last = self
	while last._next do
		last = last._next
	end
	return last
end

-------------------------------------------------------------------------------

function clsPromise:IsSelfFinished()
	return self._cur_state == STATE_DONE or self._cur_state == STATE_STOPED
end

function clsPromise:IsFinished()
	if not self:IsSelfFinished() then return false end
	if self._next then return self._next:IsFinished() end
	return true
end

function clsPromise:IsPartsFinished()
	if not self._subNodes then return true end
	for _, partlist in pairs(self._subNodes) do 
		for i, part in ipairs(partlist) do
			if not part:IsFinished() then
				logger.drama(self._node_type, "等待子节点", part._node_type)
				return false
			end
		end
	end
	return true
end

function clsPromise:OnProc()
	if self._procCaller then
		self._procCaller:Call(self)
	else 
		self._playOver = true
	end
end

function clsPromise:OnStop()
	if self._stopCaller then
		self._stopCaller:Call(self)
	end 
end

function clsPromise:SetPaused(bPaused)
	self._bPaused = bPaused
	self:walk_all(function(curNode)
		curNode._bPaused = bPaused
	end)
	if not self._bPaused then
		self:Run()
	end
end

function clsPromise:Run()
	if self._bPaused then logger.drama("已暂停") return end
	if self._cur_state == STATE_RUNNING then 
		return
	elseif self._cur_state == STATE_DONE or self._cur_state == STATE_STOPED then
		if self._next then
			self._next._belongTo = self._belongTo
			return self._next:Run()
		end
		return 
	end
	self._cur_state = STATE_RUNNING
	
	if self._next then
		self._next._belongTo = self._belongTo
	end
	
	--run self
	logger.drama("播放开始", self._node_type)
	self:OnProc() --注意 可能在OnProc中调用Done()，所以后面的逻辑需要判断此情况
	
	--run parts
	if self._subNodes then
		for evtPoint, partlist in pairs(self._subNodes) do
			if evtPoint > 0 then
				self._trigger_points[evtPoint] = KE_SetTimeout(evtPoint, function()
					self._trigger_points[evtPoint] = nil
					for _, part in ipairs(partlist) do
						part:Run()
					end
				end)
			else
				for _, part in ipairs(partlist) do
					part:Run()
				end
			end
		end
	end
	
	if self._cur_state == STATE_RUNNING and self._playOver then
		if (not self._subNodes or table.is_empty(self._subNodes)) and not self._procCaller then
		--	logger.drama("该节点是一个空节点哦",self._node_type)
			self:Done()
		end
	end
end

function clsPromise:OnPartFinished(partNode)
	if not self._playOver then 
		logger.drama("fail OnPartFinished: self not over", self._node_type, partNode._node_type, #self._trigger_points)
		return 
	end 
	if self:IsPartsFinished() then
		logger.drama("OnPartFinished", self._node_type, partNode._node_type, #self._trigger_points)
		self:Done()
	end
end

function clsPromise:Done()
	self._playOver = true
	
	if self._cur_state ~= STATE_STOPED then
		assert(self._cur_state == STATE_RUNNING, "不可Done非running状态的节点："..self._cur_state)
	end
	
	--如果有子节点 等待子节点完成
	if not self:IsPartsFinished() then return end
	
	if self._cur_state == STATE_DONE or self._cur_state == STATE_STOPED then return end
	self._cur_state = STATE_DONE
	
	self:DestroyAllTimer()
	assert(table.is_empty(self._trigger_points))
	
	-- clean
	if self._bAutoClean then
		self:Clean()
	end
	
	logger.drama("播放完成",self._node_type)
	
	if self._next then
		self._next._belongTo = self._belongTo
		return self._next:Run()
	end
	
	if self._belongTo then
		return self._belongTo:OnPartFinished(self)
	end
	logger.drama("======== 整个Promise执行完成", self._node_type)
end

function clsPromise:Stop()
	if self._cur_state == STATE_DONE or self._cur_state == STATE_STOPED then 
		if self._next then
			return self._next:Stop()
		end
		logger.drama("======== 整个Promise中断执行", self._node_type)
		return 
	end
	
	self._cur_state = STATE_STOPED
	
	self:DestroyAllTimer()
	for evtPoint, tmrId in pairs(self._trigger_points) do 
		KE_KillTimer(tmrId)
	end
	self._trigger_points = {}
	
	-- stop self
	self:OnStop()
	-- stop parts
	if self._subNodes then
		for i, partlist in pairs(self._subNodes) do
			for _, part in ipairs(partlist) do
				part:Stop()
			end
		end
	end
	
	-- clean
	if self._bAutoClean then
		self:Clean()
	end
	
	-- stop next 
	if self._next then
		self._next:Stop()
	else 
		logger.drama("======== 整个Promise中断执行")
	end
end

function clsPromise:Recover()
	if self:IsRunning() then
		logger.drama("不可对运行中的Promise进行Recover操作")
		return
	end
	-- recover self
	self._cur_state = STATE_READY
	self._playOver = false
	self._trigger_points = {}
	-- recover parts
	if self._subNodes then
		for i, partlist in pairs(self._subNodes) do
			for _, part in ipairs(partlist) do
				part:Recover()
			end
		end
	end
	-- recover next
	if self._next then
		self._next:Recover()
	end
end

function clsPromise:IsRunning()
	-- check self
	if self._cur_state == STATE_RUNNING then return true end
	-- check parts
	if self._subNodes then
		for i, partlist in pairs(self._subNodes) do
			for _, part in ipairs(partlist) do
				if part:IsRunning() then return true end
			end
		end
	end
	-- check next
	if self._next then
		return self._next:IsRunning()
	end
	return false
end

function clsPromise:walk_all(func)
	-- walk self
	if func(self) == "break" then return end
	-- walk parts
	if self._subNodes then
		for i, partlist in pairs(self._subNodes) do
			for _, part in ipairs(partlist) do
				part:walk_all(func)
			end
		end
	end
	-- walk next
	if self._next then
		self._next:walk_all(func)
	end
end

function clsPromise:HasCircle(all_promise)
	local bHas = false
	self:walk_all(function(promise) 
		--logger.drama("walk: ", promise._procCaller and promise._procCaller.args[1]) 
		if all_promise[promise] then
			logger.drama("存在环")
			bHas = true
			return "break"
		end
		all_promise[promise] = true
	end)
--	logger.drama("检查是否成环", bHas)
	return bHas
end

