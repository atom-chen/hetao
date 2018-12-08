-------------------------
-- 游戏管理器
-- k3  pcdd
-- 
-------------------------
local GAME_CID = 0
local BACKOP_INTERVAL = 3
local WANFA_INTERVAL = 0.1

ClsGameMgr = class("ClsGameMgr", clsCoreObject)
ClsGameMgr.__is_singleton = true

function ClsGameMgr:ctor()
	clsCoreObject.ctor(self)
	self._runningGame = nil 
	self._allWanFaData = {}
	self._allPeiLvData = {}
	self._allPeilvByTid = {}
	
	self._open_results = {}	--开奖结果缓存
end

function ClsGameMgr:dtor()
	if self._taskProcedure then KE_SafeDelete(self._taskProcedure) self._taskProcedure = nil end
end

function ClsGameMgr:OpenGame(gameId, gameType, gameName)
	if not ClsLoginMgr.GetInstance():IsLogonSucc() then
		ClsUIManager.GetInstance():ShowPopWnd("clsLoginUI4")
		utils.TellMe("请先登录", 1)
		return
	end
	
	local cfgInfo = const.GAME_TYPE[gameType]
	if not cfgInfo then
		utils.TellMe("敬请期待")
		return
	end
	
	if not ClsGameMgr.GetInstance():GetAllGameInfo() then
		proto.req_goucai_all_games({use="all"})
	end
	
	GAME_CID = GAME_CID + 1
	local gameArg = { gid=gameId, cptype=gameType, name=gameName, game_cid = GAME_CID }
	self._runningGame = gameArg
	
	logger.game("进入游戏......")
	self:SetTaskPaused(true)
	logger.dump(gameArg)
	ClsUIManager.GetInstance():ShowView(cfgInfo.ViewClass):SetGameArg(table.clone(gameArg))
end

function ClsGameMgr:LeaveGame()
	logger.game("离开游戏")
	self:SetTaskPaused(false)
end

function ClsGameMgr:IsGameRunning(gid) 
	gid = tonumber(gid)
	local curGid = self._runningGame and self._runningGame.gid
	curGid = tonumber(curGid)
	if not gid or not curGid then return false end
	return gid == curGid
end

--------------------------------------------------------------------

function ClsGameMgr:ReqAllWanfaData()
	if not self._allGameInfo then return end
	if not ClsLoginMgr.GetInstance():IsLogonSucc() then
		KE_SetAbsTimeout(2.5, function()
			self:ReqAllWanfaData()
		end)
		return	
	end
	if self._taskProcedure then return end
	self._taskProcedure = smartor.clsPromise.new()
	
	local info = self._allGameInfo
	for _, items in pairs(info[1]) do
		for _, item in pairs(items) do 
			local gid = tonumber(item.gid)
			local procedure = smartor.clsPromise.new(gid)
			procedure:SetProcFunc(function(thisObj, Procedure)
				local curGid = Procedure:GetArgInfo()
				proto.req_goucai_game_wanfa_list({ gid=curGid }, { gid=curGid }, function(recvdata, tArgs)
					local data = recvdata and recvdata.data
					if data then
						if data.type == "k3" then
							for idx, wanfa in ipairs(data.play[1].play) do
								local wanfaGid = tonumber(wanfa.gid)
								local wanfaTid = tonumber(wanfa.id)
								local subProcdure = smartor.clsPromise.new({ gid=wanfaGid, tid=wanfaTid })
								subProcdure:SetProcFunc(function(thisObj, subP)
									local param = subP:GetArgInfo()
									if ClsLoginMgr.GetInstance():IsLogonSucc() and not self._bTaskPaused then
										proto.req_goucai_game_qiuhao_peilv_list(param, param)
									end
									self:CreateAbsTimerDelay("tmr_task", BACKOP_INTERVAL, function() 
										self:DestroyTimer("tmr_task")
										subP:Done() 
									end)
								end)
								if self._taskProcedure then self._taskProcedure:SetNext(subProcdure) end 
								break
							end
						else
							for idx, wanfa in ipairs(data.play) do
								local wanfaGid = tonumber(wanfa.gid)
								local wanfaTid = tonumber(wanfa.id)
								local subProcdure = smartor.clsPromise.new({ gid=wanfaGid, tid=wanfaTid })
								subProcdure:SetProcFunc(function(thisObj, subP)
									local param = subP:GetArgInfo()
									if ClsLoginMgr.GetInstance():IsLogonSucc() and not self._bTaskPaused then 
										proto.req_goucai_game_qiuhao_peilv_list(param, param)
									end
									self:CreateAbsTimerDelay("tmr_task", BACKOP_INTERVAL, function() 
										self:DestroyTimer("tmr_task")
										subP:Done() 
									end)
								end)
								if self._taskProcedure then self._taskProcedure:SetNext(subProcdure) end
								break
							end
						end
					end
				end)
				self:CreateAbsTimerDelay("tmr_task", WANFA_INTERVAL, function() 
					self:DestroyTimer("tmr_task")
					Procedure:Done() 
				end)
			end)
			if self._taskProcedure then self._taskProcedure:SetNext(procedure) end
		end
	end
	
	if not self._bTaskPaused then
		if self._taskProcedure then self._taskProcedure:Run() end
	else
		self:SetTaskPaused(self._bTaskPaused)
	end
end

function ClsGameMgr:SetTaskPaused(bPaused)
	self._bTaskPaused = bPaused
	if self._taskProcedure then
		self._taskProcedure:SetPaused(bPaused)
	end
end

function ClsGameMgr:InitAllGameInfo(info)
	self._allGameInfo = info
	self:ReqAllWanfaData()
end

function ClsGameMgr:GetAllGameInfo()
	return self._allGameInfo
end

function ClsGameMgr:GetGameInfosOfType(gameType)
	if not self._allGameInfo then return nil end
	for k, infos in pairs(self._allGameInfo[1]) do
		for gid, gameInfo in pairs(infos) do
			if gameInfo.type == gameType then
				return infos
			end
		end
	end
end

--------------------------------------------------------------------

function ClsGameMgr:GetPeiLvData(gid, tid)
	return self._allPeiLvData[gid] and self._allPeiLvData[gid][tid]
end

function ClsGameMgr:GetPeiLvByTid(tid)
	return self._allPeilvByTid[tid]
end

-- 当前玩法的赔率列表（球列表）
function ClsGameMgr:SavePeiLvData(peilvList, argGid, argTid)
	self._allPeiLvData[argGid] = self._allPeiLvData[argGid] or {}
	self._allPeiLvData[argGid][argTid] = peilvList
	
	local plGid = 0
	for tid, group in pairs(peilvList.balls_rate) do
		for _, ball in pairs(group.balls) do
			plGid = ball.gid
			break
		end
		break
	end
	plGid = tonumber(plGid)
	
	for tid, groupInfo in pairs(peilvList.balls_rate) do
		groupInfo._client_user_rebate = peilvList.user_rebate
		self._allPeilvByTid[tid] = groupInfo
		
		for _, ball in pairs(groupInfo.balls) do
			if ball.child then
				for _, childBall in pairs(ball.child) do
					childBall._client_parent_ball = ball
					childBall._client_parent_group = groupInfo
					self:CalculatePeiLv(childBall)
				end
			else
				self:CalculatePeiLv(ball)
			end
		end
	end
	
--	if device.platform == "windows" then
--		table.save(peilvList, string.format("ycdata/%s_%s_peilv.lua",self.gameArg.cptype,self.gameArg.gid))
--	end
end

--------------------------------------------------------------------

function ClsGameMgr:GetGroupOfBall(ballInfo)
	return self:GetPeiLvByTid(ballInfo.tid)
end

function ClsGameMgr:GetParentBall(ballInfo)
	return ballInfo._client_parent_ball
end

function ClsGameMgr:CalculatePeiLv(ball)
	if ball._client_cal_rate then return ball._client_cal_rate end
	-- 计算赔率
	local rateInfo = self:GetBallRateInfo(ball)
	local maxRate = rateInfo.rate		--最大赔率
	local minRate = rateInfo.rate_min	--最小赔率
	local rebateInfo = self:GetBallRebateInfo(ball)
	local maxRebate = rebateInfo.maxRebate		--最大返水
	local userRebate = rebateInfo.userRebate	--用户自定义设置返水率
	local odds = 0
	if type(maxRate) == "string" and string.find(maxRate,",") then
		local t1 = string.split(maxRate, ",")
		local t2 = string.split(minRate, ",")
		local rlt = ""
		for i, n in ipairs(t1) do
			local odd_i = gameutil.CalPeiLv( tonumber(t1[i]), tonumber(t2[i]), maxRebate, userRebate )
			if rlt ~= "" then rlt = rlt .. "," end
			rlt = rlt .. odd_i
		end
		odds = rlt
	else
		odds = gameutil.CalPeiLv(maxRate, minRate, maxRebate, userRebate)
	end
	ball._client_cal_rate = odds
	return odds
end

function ClsGameMgr:GetBallRateInfo(ballInfo)
	local rateInfo = {}
	rateInfo.rate = ballInfo.rate
	rateInfo.rate_min = ballInfo.rate_min
	
	local parentBall = self:GetParentBall(ballInfo)
	if parentBall then
		if parentBall.rate and parentBall.rate ~= 0 and parentBall.rate ~= "0" then
			rateInfo.rate = parentBall.rate
		end
		if parentBall.rate_min and parentBall.rate_min ~= 0 and parentBall.rate_min ~= "0" then
			rateInfo.rate_min = parentBall.rate_min
		end
	end
	
	local groupInfo = self:GetGroupOfBall(ballInfo)
	if groupInfo.rate and groupInfo.rate ~= 0 and groupInfo.rate ~= "0" then
		rateInfo.rate = groupInfo.rate
	end
	if groupInfo.rate_min and groupInfo.rate_min ~= 0 and groupInfo.rate_min ~= "0" then
		rateInfo.rate_min = groupInfo.rate_min
	end
	
	if type(rateInfo.rate)=="string" and string.find(rateInfo.rate, ",") then
	--	print("========", rateInfo.rate, rateInfo.rate_min)
	else
		rateInfo.rate = tonumber(rateInfo.rate) or 0
		rateInfo.rate_min = tonumber(rateInfo.rate_min) or 0
	end
	
	return rateInfo
end

function ClsGameMgr:GetBallRebateInfo(ballInfo)
	local peilvData = self:GetPeiLvByTid(ballInfo.tid)
	local rebateInfo = {}
	rebateInfo.maxRebate = tonumber(peilvData._client_user_rebate.rebate) or 0
	rebateInfo.userRebate = tonumber(peilvData._client_user_rebate.user_rebate) or 0
	return rebateInfo
end

function ClsGameMgr:GetGroupRebateInfo(tid)
	local peilvData = self:GetPeiLvByTid(tid)
	local rebateInfo = {}
	rebateInfo.maxRebate = tonumber(peilvData._client_user_rebate.rebate) or 0
	rebateInfo.userRebate = tonumber(peilvData._client_user_rebate.user_rebate) or 0
	return rebateInfo
end

--------------------------------------------------------------------

-- 前序遍历
local function preorder_traversal_1(NodeInfo)
	local function Traversal(CurNode, ParentNode, i)
		if not CurNode then return end
		
		if CurNode.play then
			for idx, SubNode in ipairs(CurNode.play) do
				SubNode._client_parent_menu = CurNode
				SubNode._client_parent_menu_idx = idx
				Traversal(SubNode, CurNode, idx)
			end
		end
	end
	
	Traversal(NodeInfo)
end
function ClsGameMgr:SaveWanFaData(gid, info)
	gid = tonumber(gid)
	assert(gid == tonumber(info.id))
	self._allWanFaData[gid] = info
--	table.save( self._allWanFaData, "ycdata/T_all_wanfa.lua" )
	preorder_traversal_1(info)
end

function ClsGameMgr:GetWanfaData(gid)
	gid = tonumber(gid)
	if not self._allWanFaData[gid] then
		if setting.T_all_wanfa[gid] then
			self:SaveWanFaData(gid, setting.T_all_wanfa[gid])
		end
	end
	return self._allWanFaData[gid]
end

local function preorder_traversal_2(NodeInfo, tid)
	local function Traversal(CurNode, ParentNode)
		if not CurNode then return nil end
		
		if CurNode.play then
			for idx, SubNode in ipairs(CurNode.play) do
			--	print("+++++", SubNode.name, tid, SubNode.id, gameutil.IsSameTid(tid, SubNode.id))
				if gameutil.IsSameTid(tid, SubNode.id) then 
					return SubNode 
				else
					local tmp = Traversal(SubNode, CurNode)
					if tmp then return tmp end
				end
			end
		end
	end
	
	local findedNode = Traversal(NodeInfo)
	
	if findedNode then 
		logger.normal("findedNode", findedNode.id, findedNode.name, findedNode.sname)
	else
		logger.error("find fail", tid)
	end
	return findedNode
end

function ClsGameMgr:GetMenuOfGroup(gid, tid)
	gid = tonumber(gid)
	if not gid then return nil end
	local curWanfa = self._allWanFaData[gid]
	if not curWanfa then return nil end
	if not curWanfa.play then
		assert(gameutil.IsSameTid(curWanfa.id, tid))
		return curWanfa
	end
	return preorder_traversal_2(curWanfa, tid)
end

function ClsGameMgr:IsUnderMenu(gid, tid, sname)
	local groupMnu = self:GetMenuOfGroup(gid, tid)
	if not groupMnu then return false end
	local parentMnu = groupMnu
	while parentMnu do
		if parentMnu.sname == sname then
			return true
		else
			parentMnu = parentMnu._client_parent_menu
		end
	end
end

-----------------------------------

function ClsGameMgr:SaveGameSate(gid, recvdata)
	if not gid then return end
	self._games_state = self._games_state or {}
	self._games_state[gid] = recvdata
	local data = recvdata and recvdata.data and recvdata.data[1]
	if data then
		local remainSec = data.kithe_time_stamp - data.current_time_stamp
		recvdata._client_curtime = math.ceil(os.clock()) or data.current_time_stamp
		recvdata._client_expire = recvdata._client_curtime + remainSec
	end
end

function ClsGameMgr:GetGameSate(gid)
	if self._games_state and self._games_state[gid] then
		local recvdata = self._games_state[gid]
		if recvdata._client_expire then
			local curTime = math.ceil(os.clock())
			if curTime < recvdata._client_expire then
				local data = recvdata and recvdata.data and recvdata.data[1]
				if data then
					data.current_time_stamp = data.current_time_stamp + curTime - recvdata._client_curtime
				end
				return recvdata
			else
				self._games_state[gid] = nil
			end
		end
		return self._games_state[gid]
	end
end

function ClsGameMgr:SaveOpenResult(gid, recvdata)
	if not gid then return end
	gid = tostring(gid)
	self._open_results[gid] = recvdata
end

function ClsGameMgr:GetOpenResult(gid)
	gid = tostring(gid)
	return self._open_results[gid]
end
