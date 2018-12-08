----------------------------------
-- 下注单
----------------------------------
clsBillPaper = class("clsBillPaper", clsCoreObject)

function clsBillPaper:ctor()
	clsCoreObject.ctor(self)
	self._tBillObjList = {}
end

function clsBillPaper:dtor()
	
end

function clsBillPaper.Clone(who)
	local billPaper = clsBillPaper.new()
	billPaper._tBillObjList = {}
	for i, v in pairs(who._tBillObjList) do
		billPaper._tBillObjList[i] = clsBetBill.Clone(v)
	end
	return billPaper
end

function clsBillPaper:SetKithe(kithe)
	self._kithe = kithe
end
function clsBillPaper:GetKithe()
	return self._kithe
end

function clsBillPaper:SetCost(cost)
	for _, billObj in ipairs(self._tBillObjList) do
		billObj:SetCost(cost)
	end
end

function clsBillPaper:IsEmpty()
	if not self._tBillObjList or #self._tBillObjList <= 0 then return true end
	return false
end

function clsBillPaper:GetBillList()
	return self._tBillObjList
end

function clsBillPaper:CheckValid(gameObj, bCheckMoney, bShowTips)
	if self:IsEmpty() then
		if bShowTips then utils.TellMe("请先选择号码") end
		return false
	end
	local cnt = #self._tBillObjList
	for i=cnt, 1, -1 do
		if not self._tBillObjList[i]:CheckValid(gameObj, bCheckMoney, bShowTips) then
			return false
		end
	end
	return true
end

function clsBillPaper:RemoveInvalidBills(gameObj)
	local cnt = #self._tBillObjList
	for i=cnt, 1, -1 do
		if not self._tBillObjList[i]:CheckValid(gameObj) then
			print("移除无效注单：", i)
			table.remove(self._tBillObjList, i)
		end
	end
end

function clsBillPaper:HasValidBill(gameObj)
	local cnt = #self._tBillObjList
	for i=cnt, 1, -1 do
		if self._tBillObjList[i]:CheckValid(gameObj) then
			return true
		end
	end
	return false
end

function clsBillPaper:DelBall(ballId)
	local cnt = #self._tBillObjList
	for i=cnt, 1, -1 do
		self._tBillObjList[i]:DelBall(ballId)
		if self._tBillObjList[i]:IsEmpty() then
			self:DelBillObjByIdx(i)
		end
	end
end
function clsBillPaper:compute(cost,gameObj)
	cost = tonumber(cost)
	if not cost or not gameObj then return 0 end
    local _ttids = {0}
    local _tmoney = {0}
    --将玩法的tid号统计，避免重复的tid号
    for _,info in ipairs(self._tBillObjList) do
        for c,v in ipairs(_ttids) do
            if info.tid ~= v then
                table.insert(_ttids,info.tid)
            end
        end
    end
    --统计每个tid号的最大赔率
    for _,info in ipairs(self._tBillObjList) do
        for c,v in ipairs(_ttids) do
			if info.tid == v then
				local peilv = tonumber( gameObj:CalculatePeiLv(info.ball_list[1]) ) or 1
                local xx = peilv * cost
                if not _tmoney[v] then
                    _tmoney[v] = xx
                elseif xx > _tmoney[v] then
                    _tmoney[v] = xx
                end
            end
        end
    end
    local mm = 0
    for _,info in pairs (_tmoney) do
        mm = mm + info
    end
    return mm
end

function clsBillPaper:AddBall(cost, ball, gameObj, bShowTips)
	local gid = gameObj:GetGid()
	local tid = ball.tid
	local combInfo = gameObj:GetBallCombineInfo(tid)

	if not combInfo then
		logger.error("球组数据尚未返回", ball.tid)
		if bShowTips then
			utils.TellMe("数据刷新中，请耐心等待")
		end
		return false
	end
	local billType, onceCnt, maxCnt = combInfo.billType, combInfo.onceCnt, combInfo.maxCnt
	local billObj = self:FindBillObjByTid(tid)
	if billObj then
		local flag, tipStr = billObj:AddBall(cost, ball, gameObj)
		if not flag then
			if billType == const.BILL_TYPE.SINGLE then
				billObj = clsBetBill.new(gid, tid, billType, onceCnt, maxCnt, cost)
				flag, tipStr = billObj:AddBall(cost, ball, gameObj)
				if flag then
					table.insert(self._tBillObjList, billObj)
				else
					if bShowTips then utils.TellMe(tipStr) end
				end
			elseif bShowTips then
				utils.TellMe(tipStr)
			end
		end
		return flag
	else
		billObj = clsBetBill.new(gid, tid, billType, onceCnt, maxCnt, cost)
		local flag, tipStr = billObj:AddBall(cost, ball, gameObj)
		if flag then
			table.insert(self._tBillObjList, billObj)
		else
			if bShowTips then utils.TellMe(tipStr) end
		end
		return flag
	end
end

function clsBillPaper:FindBillObjByTid(tid)
	for _, billObj in ipairs(self._tBillObjList) do
		if billObj.tid == tid then
			return billObj
		end
	end
end

function clsBillPaper:DelBillObj(billId)
	for idx, bill in ipairs(self._tBillObjList) do
		if bill.billId == billId then
			self:DelBillObjByIdx(idx)
			return 
		end
	end
end

function clsBillPaper:DelBillObjByIdx(idx)
	if self._tBillObjList[idx] then
		logger.warn("移除Bill", idx, self._tBillObjList[idx].billId)
		table.remove(self._tBillObjList, idx)
	end
end

function clsBillPaper:Clear()
	self._tBillObjList = {}
end

function clsBillPaper:GetTotalInfo(gameObj)
	local betCount = 0
	local totalCost = 0
	for _, oneBill in pairs(self._tBillObjList) do
		local totalInfo = oneBill:GetTotalInfo()
		if totalInfo then
			betCount = betCount + totalInfo.zuheCount
			totalCost = totalCost + totalInfo.totalCost
		end
	end
	print("GetTotalInfo: ", #self._tBillObjList, betCount, totalCost)
	return betCount, totalCost
end

function clsBillPaper:SendBill(gameObj)
	local infoList = {}
	local bills = {}
	for _, oneBill in pairs(self._tBillObjList) do
		local billInfo = oneBill:GenSenderBill(gameObj)
		if billInfo then
			table.insert(infoList, billInfo)
			table.insert(bills, oneBill)
		else
			logger.error("下注单发送失败，不是有效的下注单：", oneBill:GetBillId())
		end
	end
	
	if #infoList > 0 then
		local billStr = json.encode(infoList)
		proto.req_bet_xiazhu( {bets=billStr}, { gid=tostring(gameObj:GetGid()) }, function(recvdata)
				if proto.is_success(recvdata) then 
					logger.warn("下注单发送成功")
					local count = #bills
					for i=count, 1, -1 do
						local oneBill = bills[i]
						self:DelBillObj(oneBill:GetBillId())
						g_EventMgr:FireEvent("GAME_BILL_SUCC", oneBill:GetBillId(), oneBill, self, gameObj)
					end
					local function callback(mnuId)
						if mnuId == 0 then
							ClsUIManager.GetInstance():ShowPanel("clsBetHistoryView")
						end
					end
					ClsUIManager.GetInstance():PopConfirmDlg("CFM_CLEAR_BET", "提示", "你已成功下注", callback, "继续投注", "查看注单")
					
					KE_SetTimeout(2, function() proto.req_user_balance() end)
				end
		end )
	end
end
