clsGameInterface = class("clsGameInterface", clsCoreObject)

function clsGameInterface:ctor()
	clsCoreObject.ctor(self)
	self._billPaper = nil
end

function clsGameInterface:dtor()
	
end

-- 打开游戏(OpenGame时设置)
function clsGameInterface:SetGameArg(gameArg)
	self.gameArg = gameArg
end

-- 离开游戏时清除
function clsGameInterface:LeaveGame()
	self._gameStateInfo = nil
	self._wanfaList = nil
	self._curWanfa = nil
end

-- 游戏的状态信息（游戏名称等信息、开奖状态、倒计时、开奖结果等）
-- req_bet_game_state协议的返回数据
function clsGameInterface:SetGameStateInfo(gameInfo)
	if tonumber(gameInfo.gid) ~= tonumber(self.gameArg.gid) then
		logger.error("gid不一致", gameInfo.gid, self.gameArg.gid)
		return nil
	end
	
	self._gameStateInfo = gameInfo
	
--	if device.platform == "windows" then
--		table.save(gameInfo, string.format("ycdata/%s_%s_state.lua",self.gameArg.cptype,self.gameArg.gid))
--	end
	
	return self._gameStateInfo
end

-- 玩法列表
function clsGameInterface:SetWanFaList(wanfaList)
	if tonumber(wanfaList.id) ~= tonumber(self.gameArg.gid) then
		logger.error("gid不一致", wanfaList.id, self.gameArg.gid)
		return nil
	end
	
	self._wanfaList = wanfaList
	
--	if device.platform == "windows" then
--		table.save(wanfaList, string.format("ycdata/%s_%s_wanfa.lua",self.gameArg.cptype,self.gameArg.gid))
--	end
	
	return self._wanfaList
end

-- 选择当前玩法
function clsGameInterface:SetCurWanFa(curWanfa)
	if tonumber(curWanfa.gid) ~= tonumber(self.gameArg.gid) then
		logger.error("gid不一致", curWanfa.gid, self.gameArg.gid)
		return nil
	end
	
	self._curWanfa = curWanfa
	g_EventMgr:FireEvent("GAME_CUR_WANFA", curWanfa)
	return self._curWanfa
end

-- 当前玩法的赔率列表（球列表）
function clsGameInterface:SetCurPeiLvList(peilvList, argTid, argTid)
	
end

--------------------------------------------------------------------

function clsGameInterface:GetGroupOfBall(ballInfo)
	return ClsGameMgr.GetInstance():GetPeiLvByTid(ballInfo.tid)
end

function clsGameInterface:GetParentBall(ballInfo)
	return ClsGameMgr.GetInstance():GetParentBall(ballInfo)
end

function clsGameInterface:CalculatePeiLv(ball)
	return ClsGameMgr.GetInstance():CalculatePeiLv(ball)
end

function clsGameInterface:GetBallRateInfo(ballInfo)
	return ClsGameMgr.GetInstance():GetBallRateInfo(ballInfo)
end

function clsGameInterface:GetBallRebateInfo(ballInfo)
	return ClsGameMgr.GetInstance():GetBallRebateInfo(ballInfo)
end

function clsGameInterface:GetGroupRebateInfo(tid)
	return ClsGameMgr.GetInstance():GetGroupRebateInfo(tid)
end

--------------------------------------------------------------------

function clsGameInterface:GetGid()
	return self.gameArg.gid
end

function clsGameInterface:GetGameStateInfo()
	return self._gameStateInfo
end

function clsGameInterface:GetCurWanfa()
	return self._curWanfa
end

function clsGameInterface:GetMenuOfGroup(gid, tid)
	if gid == nil then gid = self.gameArg.gid end
	return ClsGameMgr.GetInstance():GetMenuOfGroup(gid, tid)
end
function clsGameInterface:IsUnderMenu(gid, tid, sname)
	if gid == nil then gid = self.gameArg.gid end
	return ClsGameMgr.GetInstance():IsUnderMenu(gid, tid, sname)
end
function clsGameInterface:GetWanfaData(gid)
	if gid == nil then gid = self.gameArg.gid end
	return ClsGameMgr.GetInstance():GetWanfaData(gid)
end

--------------------------------------------------------------------

function clsGameInterface:GetBallCombineInfo(tid)
	assert(false, "子类重载该方法")
end

function clsGameInterface:SetBillPaper(billPaper, kithe)
	self._billPaper = clsBillPaper.Clone( billPaper )
	self._billPaper:SetKithe(kithe)
	g_EventMgr:FireEvent("GAME_ADD_BILLPAPER", self._billPaper, self)
end

function clsGameInterface:DelBillPaper()
	KE_SafeDelete(self._billPaper)
	self._billPaper = nil
	g_EventMgr:FireEvent("GAME_DEL_BILLPAPER", self)
end

function clsGameInterface:GetBillPaper()
	return self._billPaper
end

function clsGameInterface:DelBillObj(billId)
	if self._billPaper then
		self._billPaper:DelBillObj(billId)
	end
end

function clsGameInterface:SendBill()
	if self._billPaper then
		self._billPaper:SendBill(self)
	else
		logger.error("尚未下注")
	end
end