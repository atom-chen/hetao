----------------------------------
-- 下注单
----------------------------------
local AUTO_BILL_ID = 0

clsBetBill = class("clsBetBill", clsCoreObject)

function clsBetBill:ctor(gid, tid, billType, onceCnt, maxCnt, cost)
	clsCoreObject.ctor(self)
	
	local flag, str = TYPE_CHECKER.BILL_TYPE(billType) 
	assert(flag, str)
	if maxCnt > 0 then assert(maxCnt>=onceCnt) end
	
	AUTO_BILL_ID = AUTO_BILL_ID + 1
	self.billId = AUTO_BILL_ID
	self.gid = gid
	self.tid = tid
	self.billType = billType
	self.onceCnt = onceCnt
	self.maxCnt = maxCnt
	self.cost = cost or 0
	self.ball_list = {}
end

function clsBetBill.Clone(who)
	local oneBill = clsBetBill.new(who.gid, who.tid, who.billType, who.onceCnt, who.maxCnt, who.cost)
	oneBill.ball_list = {}
	for _, ball in ipairs(who.ball_list) do
		table.insert(oneBill.ball_list, ball)
	end
	return oneBill
end

function clsBetBill:dtor()
	
end

function clsBetBill:GetBillId()
	return self.billId
end

function clsBetBill:SetCost(cost)
	assert(cost>=0)
	self.cost = cost
end

function clsBetBill:AddBall(cost, ball, gameObj)
	if gameObj:GetGid() ~= self.gid then
		logger.error("gid不一致")
		return false, "gid不一致"
	end
	if ball.tid ~= self.tid then
		logger.error("tid不一致")
		return false, "tid不一致"
	end
	
	local combInfo = gameObj:GetBallCombineInfo(ball.tid)
	if not combInfo then
		logger.error("球组数据尚未返回", ball.tid)
		return false, "数据刷新中，请耐心等待"
	end
	local billType, onceCnt, maxCnt = combInfo.billType, combInfo.onceCnt, combInfo.maxCnt
	if billType ~= self.billType then
		logger.error("billType不一致")
		return false, "billType不一致"
	end
	if onceCnt ~= self.onceCnt then
		logger.error("onceCnt不一致")
		return false, "onceCnt不一致"
	end
	if maxCnt ~= self.maxCnt then
		logger.error("maxCnt不一致")
		return false, "maxCnt不一致"
	end
	
	if cost ~= self.cost then
		logger.error("价钱需要设置为"..self.cost)
		return false, "价钱需要设置为"..self.cost
	end
	
	if self.billType == const.BILL_TYPE.ZHIXUAN then 
		local ballByPid = {}
		local ballByName = {}
		for _, tmp in ipairs(self.ball_list) do
			ballByName[tmp.name] = true
			ballByPid[tmp.pid] = ballByPid[tmp.pid] or 0
			ballByPid[tmp.pid] = ballByPid[tmp.pid] + 1
			
			if ballByPid[tmp.pid] >= onceCnt and ball.pid == tmp.pid then
				logger.error("pid超出个数", tmp.pid, ballByPid[tmp.pid], onceCnt)
				return false, "最多可选"..onceCnt.."个"
			end
		end
		if ballByName[ball.name] then
			logger.error("不可添加同名ball")
			return false, "直选玩法同一组下不可选择同名球号"
		end
	elseif self.billType == const.BILL_TYPE.MULTY_GRP then 
		local ballByPid = {}
		for _, tmp in ipairs(self.ball_list) do
			ballByPid[tmp.pid] = ballByPid[tmp.pid] or 0
			ballByPid[tmp.pid] = ballByPid[tmp.pid] + 1
			
			if ballByPid[tmp.pid] >= onceCnt and ball.pid == tmp.pid then
				logger.error("pid超出个数", tmp.pid, ballByPid[tmp.pid], onceCnt)
				return false, "最多可选"..onceCnt.."个"
			end
		end
	else
		if self.maxCnt > 0 then
			if #self.ball_list >= self.maxCnt then
				logger.error("最多可选取"..self.maxCnt.."个")
				return false, "最多可选取"..self.maxCnt.."个"
			end
		end
	end
	
	if self:GetBallIdx(ball.id) then
		logger.error("已经添加过该球",ball.id, self:GetBallIdx(ball.id))
		return false, "已经添加过该球"
	end
	
	table.insert(self.ball_list, ball)
	logger.normal( string.format("添加Ball： id=%s  name=%s  billType=%s  onceCnt=%d  maxCnt=%d  #ball_list=%d",ball.id,ball.name,billType,onceCnt,maxCnt,#self.ball_list) )
	
	return true
end

function clsBetBill:DelBall(ballId)
	local idx = self:GetBallIdx(ballId)
	if idx then 
		table.remove(self.ball_list, idx)
		logger.warn("移除ball", self.billId, idx, ballId)
		return true
	end
	return false
end

function clsBetBill:GetBallIdx(ballId)
	for idx, ball in ipairs(self.ball_list) do
		if ballId == ball.id then
			return idx
		end
	end
end

function clsBetBill:IsEmpty()
	return #self.ball_list <= 0
end

function clsBetBill:GetMenuName(gameObj)
	local grpInfo = gameObj:GetMenuOfGroup(self.gid, self.tid)
	return grpInfo and grpInfo.name or ""
end

function clsBetBill:CheckValid(gameObj, bCheckMoney, bShowTips)
	if bCheckMoney then
		if not self.cost or self.cost <= 0 then 
			logger.error("注单无效, 请输入下注金额")
			if bShowTips then utils.TellMe("请输入投注金额") end
			return false
		end
		if const.MIN_BET_MONEY and const.MIN_BET_MONEY > 0 and self.cost < const.MIN_BET_MONEY then
			logger.error("注单无效, 下注额不得低于："..const.MIN_BET_MONEY)
			if bShowTips then utils.TellMe("下注额不得低于："..const.MIN_BET_MONEY) end
			return false
		end
		if const.MAX_BET_MONEY and const.MAX_BET_MONEY > 0 and self.cost > const.MAX_BET_MONEY then
			logger.error("注单无效, 下注额不得高于："..const.MAX_BET_MONEY)
			if bShowTips then utils.TellMe("下注额不得高于："..const.MAX_BET_MONEY) end
			return false
		end
	end
	
	if gameObj:GetGid() ~= self.gid then
		logger.error("注单无效, gid不一致", gameObj:GetGid(), self.gid)
		if bShowTips then 
			utils.TellMe("注单无效, gid不一致")
		end
		return false	
	end
	
	local tid = self.tid
	local billType, onceCnt, maxCnt = self.billType, self.onceCnt, self.maxCnt
	local balls = self.ball_list
	if maxCnt > 0 then assert(maxCnt >= onceCnt) end
	local grpInfo = gameObj:GetMenuOfGroup(self.gid, tid)
	if not grpInfo then
		logger.error("尚未拉取球组数据: ",tid)
		if bShowTips then
			utils.TellMe("数据刷新中，请耐心等待")
			return false
		end
	end
	local ballCnt = #balls
	
	if ballCnt < onceCnt then
		logger.error("注单无效: ", grpInfo.id, grpInfo.sname)
		logger.error(string.format("%s组的注单无效，最少需要选择%d个球",grpInfo.name,onceCnt))
		if bShowTips then 
			utils.TellMe(string.format("%s组的注单无效，最少需要选择%d个球",grpInfo.name,onceCnt))
		end
		return false
	end
	
	if self.billType == const.BILL_TYPE.ZHIXUAN then 
		local groups = {}
		local ballByPid = {}
		for _, tmp in ipairs(self.ball_list) do
			ballByPid[tmp.pid] = ballByPid[tmp.pid] or 0
			ballByPid[tmp.pid] = ballByPid[tmp.pid] + 1
			local group = gameObj:GetGroupOfBall(tmp)
			groups[group] = true
		end
		for group, _ in pairs(groups) do
			local flag1 = true
			for _, parBall in ipairs(group.balls) do
				if ballByPid[parBall.id] ~= onceCnt then
					flag1 = false
					logger.error("个数不满足", parBall.id, onceCnt, ballByPid[parBall.id])
					break
				end
			end
			if not flag1 then
				local wanfaDesc = gameObj:GetMenuOfGroup(self.gid, self.tid)
				logger.error( string.format("%s必须每组选择%d个",wanfaDesc.name,onceCnt) )
				if bShowTips then 
					utils.TellMe(string.format("%s必须每组选择%d个",wanfaDesc.name,onceCnt))
				end
				return false
			end
		end
	elseif self.billType == const.BILL_TYPE.MULTY_GRP then
		local groups = {}
		local ballByPid = {}
		for _, tmp in ipairs(self.ball_list) do
			ballByPid[tmp.pid] = ballByPid[tmp.pid] or 0
			ballByPid[tmp.pid] = ballByPid[tmp.pid] + 1
			local group = gameObj:GetGroupOfBall(tmp)
			groups[group] = true
		end
		for group, _ in pairs(groups) do
			local flag1 = true
			local selectedGrpCnt = 0
			for _, parBall in ipairs(group.balls) do
				if ballByPid[parBall.id] ~= nil then
					selectedGrpCnt = selectedGrpCnt + 1
					if ballByPid[parBall.id] ~= onceCnt then
						flag1 = false
						logger.error("个数不满足", parBall.id, onceCnt, ballByPid[parBall.id])
						break
					end
				end
			end
			if not flag1 then
				local wanfaDesc = gameObj:GetMenuOfGroup(self.gid, self.tid)
				logger.error( string.format("%s必须每组选择%d个",wanfaDesc.name,onceCnt) )
				if bShowTips then 
					utils.TellMe(string.format("%s必须每组选择%d个",wanfaDesc.name,onceCnt))
				end
				return false
			end
			if selectedGrpCnt < 2 then
				if bShowTips then
					utils.TellMe("至少需要选择2组")
				end
				return false 
			end
		end
	else
		if maxCnt > 0 and ballCnt > maxCnt then
			logger.error("注单无效: ", grpInfo.id, grpInfo.sname)
			logger.error(string.format("%s组的注单无效，最多可选择%d个球", grpInfo.name, maxCnt))
			if bShowTips then 
				utils.TellMe(string.format("%s组的注单无效，最多可选择%d个球", grpInfo.name, maxCnt))
			end
			return false
		end
	end
	
	return true
end

function clsBetBill:GetTotalInfo()
	local billType, onceCnt, maxCnt = self.billType, self.onceCnt, self.maxCnt
	local cost = self.cost or 0
	local zuheCount = 1
	if billType == const.BILL_TYPE.MxN or billType == const.BILL_TYPE.MzN then 
		zuheCount = gameutil.CalCmn(#self.ball_list, onceCnt)
	end
	local totalCost = zuheCount * cost
	
	local totalInfo = {
		totalCost = totalCost,
		zuheCount = zuheCount,
	}
	return totalInfo
end

function clsBetBill:GenSenderBill(gameObj)
	if not self:CheckValid(gameObj, true) then return nil end
	
	local dott = ","
	local rateStr = ""
	local pidStr = ""
	local contStr = ""
	local namesStr = ""
	
	if self.billType == const.BILL_TYPE.ZHIXUAN or self.billType == const.BILL_TYPE.MULTY_GRP then 
		dott = "|" 
	end
	
	if self.billType == const.BILL_TYPE.MULTY_GRP then
		local group = gameObj:GetGroupOfBall(self.ball_list[1])
		for iiii, parBall in ipairs(group.balls) do
			local bFlag = false 
			for idx, ball in ipairs(self.ball_list) do
				if ball.pid == parBall.id then
					bFlag = true 
					-- 计算赔率
					local odds = gameObj:CalculatePeiLv(ball)
					-- 拼接赔率
					if rateStr ~= "" then rateStr = rateStr .. "," end
					rateStr = rateStr .. odds
					-- 拼接pids
					if pidStr ~= "" then pidStr = pidStr .. dott end
					pidStr = pidStr .. ball.id
					-- 拼接contents
					if contStr ~= "" then contStr = contStr .. dott end
					contStr = contStr .. ball.code
					-- 拼接names
					if namesStr ~= "" then namesStr = namesStr .. dott end
					namesStr = namesStr .. ball.name
				end
			end
			if not bFlag then
				-- 拼接pids
				if iiii ~= 1 then pidStr = pidStr .. dott end
				-- 拼接contents
				if iiii ~= 1 then contStr = contStr .. dott end
				-- 拼接names
				if iiii ~= 1 then namesStr = namesStr .. dott end
			end
		end
	else
		for idx, ball in ipairs(self.ball_list) do
			-- 计算赔率
			local odds = gameObj:CalculatePeiLv(ball)
			
			-- 拼接赔率
			if self.billType == const.BILL_TYPE.MULTY_GRP then
				if rateStr ~= "" then rateStr = rateStr .. "," end
				rateStr = rateStr .. odds
			elseif self.billType == const.BILL_TYPE.LHC_HX then
				local tbl = string.split(odds, ",")
				rateStr = tbl[#self.ball_list]
			else
				rateStr = tostring(odds)
			end
			-- 拼接pids
			if pidStr ~= "" then pidStr = pidStr .. dott end
			pidStr = pidStr .. ball.id
			-- 拼接contents
			if contStr ~= "" then contStr = contStr .. dott end
			contStr = contStr .. ball.code
			-- 拼接names
			if namesStr ~= "" then namesStr = namesStr .. dott end
			namesStr = namesStr .. ball.name
		end
	end
	
	--计算总花费
	local totalInfo = self:GetTotalInfo()
	
	--生成发送信息
	local billInfo = {
		gid = self.gid,
		tid = self.tid,
		price = self.cost,
		counts = totalInfo.zuheCount,		--
		price_sum = totalInfo.totalCost,	--
		rate = rateStr,			--
		rebate = tostring(gameObj:GetGroupRebateInfo(self.tid).userRebate),
		pids = pidStr,			--
		contents = contStr,		--
		names = namesStr,		--
	}
	
	return billInfo
end