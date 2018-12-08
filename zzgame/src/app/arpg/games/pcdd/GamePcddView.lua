-------------------------
-- PC蛋蛋
-------------------------
module("ui", package.seeall)

clsGamePcddView = class("clsGamePcddView", clsBaseUI)

function clsGamePcddView:ctor(parent,gameArg)
	clsBaseUI.ctor(self, parent, "uistu/GamePcdd.csb")
	self.ScrollViewGame = self.AreaAuto
	self.EditMoney = utils.ReplaceTextField(self.EditMoney)
	self.EditMoney:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
	if const.MAX_BET_LENGTH then self.EditMoney:setMaxLength(const.MAX_BET_LENGTH) end
	self.ScrollViewGame:setScrollBarWidth(5)
	self.ScrollViewGame:setScrollBarPositionFromCorner(cc.p(2,2)) 
	
	ClsLayerManager.GetInstance():SetKeyboardAniDelegate({self.AreaBottom},40)
	
	self.NodeWait:setPositionX(self.NodeLottery:getPositionX())
	
	self._diceList = {}
	self._btnFeatureList = {}
	self._gameObj = ClsGamePcddMgr.GetInstance()
	self._billPaper = clsBillPaper.new()
	
	self:ClearSelectedBalls()
	self:InitUiEvents()
	self:InitGlbEvents()
	
	if gameArg then
		self:SetGameArg(gameArg)
	end
end

function clsGamePcddView:dtor()
	ClsLayerManager.GetInstance():SetKeyboardAniDelegate()
	ClsGamePcddMgr.GetInstance():DelListener(self)
	ClsGameMgr.GetInstance():LeaveGame()
end

function clsGamePcddView:SetGameArg(gameArg)
	self._kithe = nil 
	self._preIssueData = nil
	self.gameArg = gameArg
	self._gameObj:SetGameArg(gameArg)
	
	self.lblGameName:setString(gameArg.name or "")
	self:RefleshBallsArea(nil)
	self.lblCurrent:setString("投注截止")
	self.lblCountDown:setString("")
	self.lblWangQi:setString("开奖号码")
	self.NodeWait:removeAllChildren()
	self._effSaizi = nil
	self.NodeLottery:removeAllChildren()
	self._diceList = nil
	--初始假动画
	if not self._effSaizi then
			--self._effSaizi = ui.clsPicLabel.new()  -- utils.CreateLabel("正在开奖", 28, const.COLOR.BLACK)
            self._effSaizi = self:CreateAnimation()
			self.NodeWait:addChild(self._effSaizi)
			self._effSaizi:setAnchorPoint(cc.p(0.5,0.5))
			--self._effSaizi:setString("正,在,开,奖")
	end
	self:StartCD(10, gameArg.gid)
	
	self:on_req_bet_game_state(ClsGameMgr.GetInstance():GetGameSate(gameArg.gid), {gid=gameArg.gid}, true)
	self:on_req_bet_open_result(ClsGameMgr.GetInstance():GetOpenResult(gameArg.gid), {gid=gameArg.gid})
	
	proto.req_bet_game_state({gid=gameArg.gid})
	if ClsGameMgr.GetInstance():GetWanfaData(gameArg.gid) then
		print("从缓存读取玩法")
		self:on_req_goucai_game_wanfa_list({data=ClsGameMgr.GetInstance():GetWanfaData(gameArg.gid)}, { gid=gameArg.gid })
	else
		proto.req_goucai_game_wanfa_list({ gid=gameArg.gid }, { gid=gameArg.gid })
	end
	proto.req_bet_open_result({gid=gameArg.gid})
	
	proto.req_user_balance()
	ClsCollectMgr.GetInstance():req_user_get_favorite()
	self:RefleshCollectBtn()
end

--注册控件事件
function clsGamePcddView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() 
		self:quitListener()
	end)
	utils.RegClickEvent(self.BtnClear, function() 
		self:ClearSelectedBalls()
	end)
	utils.RegClickEvent(self.BtnSelect, function() 
		ClsUIManager.GetInstance():ShowPopWnd("clsGameSelectView"):RefleshUI(self.gameArg.gid, self.gameArg.cptype)
	end)
	utils.RegClickEvent(self.BtnPlayType, function() 
		if not self._wanfaList then return end
		ClsUIManager.GetInstance():ShowPopWnd("clsPlayTypeSelectWnd1"):RefleshUI(self._selectedWanFa, self._wanfaList.play, 3, function(info)
			self._gameObj:SetCurWanFa(info)
		end)
	end)
	self.EditMoney:registerScriptEditBoxHandler(function(evenName, sender)
		if evenName == "return" then 
			local money = self.EditMoney:getString() or ""
			if money ~= "" then
				local pos = string.find(money, "%.")
				if pos then
					money = string.sub(money, 1, pos+1)
				end
				money = tonumber(money) or 0
				if money <= 0 then money = 0 end
				if const.MAX_BET_MONEY and money > const.MAX_BET_MONEY then 
					money = const.MAX_BET_MONEY 
					utils.TellMe("下注额不得高于："..const.MAX_BET_MONEY) 
				end
				if const.MIN_BET_MONEY and money < const.MIN_BET_MONEY then
					money = const.MIN_BET_MONEY
				end
				if money <= 0 then money = "" end
				self.EditMoney:setString(money)
			end
		elseif evenName == "changed" then
			local fixMoney = self.EditMoney:getString() or ""
			
			local money = tonumber(fixMoney) or 0
			if const.MAX_BET_MONEY and  money > const.MAX_BET_MONEY then
				utils.TellMe("下注额不得高于："..const.MAX_BET_MONEY)
			end
			
			local pos = string.find(fixMoney, "%.")
			if pos then
				fixMoney = string.sub(fixMoney, 1, pos+1)
			end
			if fixMoney ~= self.EditMoney:getString() then
				self:DestroyTimer("chgmony")
				self:CreateTimerDelay("chgmony", 1, function() self.EditMoney:setString(fixMoney) end)
			end
		end
		self:OnSelectBallChanged()
	end)
	utils.RegClickEvent(self.BtnHistory, function() 
		ClsUIManager.GetInstance():ShowPopWnd("clsPcddHistory"):SetGid(self.gameArg.gid)
	end)
	
	utils.RegClickEvent(self.BtnAdd, function() 
		self._billPaper:SetCost(self:GetCost())
		if self._billPaper:CheckValid(self._gameObj, true, true) then
			self._gameObj:SetBillPaper(self._billPaper, self._kithe)
		end
	end)
	utils.RegClickEvent(self.BtnBasket, function() 
		self._billPaper:SetCost(self:GetCost())
		if self._billPaper:CheckValid(self._gameObj,true,true) then
			self._gameObj:SetBillPaper(self._billPaper, self._kithe)
			ClsUIManager.GetInstance():ShowPopWnd("clsBetBasketV"):RefleshUI(self._gameObj)
		end
	end)
	
	if self.BtnBerRecort then
		utils.RegClickEvent(self.BtnBerRecort, function() 
        	ClsUIManager.GetInstance():ShowPanel("clsBetHistoryView")
		end)
	end
	
	utils.RegClickEvent(self.BtnShake, function() 
		self:RandSelect()
	end)
	local shakeLayer = utils.AddShakeEvent(nil, nil, function() self:RandSelect() end)
	if shakeLayer then self:addChild(shakeLayer) end
	utils.RegClickEvent(self.CheckBoxCollect, function() 
		local status = "0"
        if ClsCollectMgr.GetInstance():HasCollect(self.gameArg.gid) then status = "1" end
        local stateInfo = self._gameObj:GetGameStateInfo() or {}
        local tArgs = { 
        	gid = tostring(self.gameArg.gid),
        	status = status,
        	id = tostring(self.gameArg.gid),
        	img = stateInfo.img,
        	name = self.gameArg.name or stateInfo.name,
        	type = stateInfo.cptype,
        }
        proto.req_user_set_favorite(tArgs)
	end)
	utils.RegClickEvent(self.BtnHelpDoc, function() 
		ClsUIManager.GetInstance():ShowPanel("clsHelpDocView"):ShowPage(self.gameArg.cptype)
	end)
end

function clsGamePcddView:quitListener()
	if self._billPaper:IsEmpty() then
		self:removeSelf()
		return
	end
	ClsUIManager.GetInstance():PopConfirmDlg("CFM_LEAVE_PLAY", "提示", "您确定要清除当前下注并离开游戏？", function(mnuId)
		if mnuId == 1 then
			self:removeSelf()
			ClsUIManager.GetInstance():ShowView("clsHallUI")
		end
	end) 
end

function clsGamePcddView:RandSelect()
	if self._btnFeatureList and #self._btnFeatureList>=1 then
		if self._preSelect and utils.IsValidCCObject(self._preSelect) then
			self._preSelect:SetSelectedQuiet(false)
			self._billPaper:DelBall(self._preSelect._info.id)
			self:OnSelectBallChanged()
		end
		
		local curBtn = self._btnFeatureList[math.random(1,#self._btnFeatureList)]
		
		if self._billPaper:AddBall(self:GetCost(), curBtn._info, self._gameObj, true) then
			self._preSelect = curBtn
			curBtn:SetSelectedQuiet(true)
			self:OnSelectBallChanged()
			local curY = curBtn:getPositionY() + curBtn:getContentSize().height / 2
			local sz = self.ScrollViewGame:getInnerContainerSize()
			local percent = math.ceil((sz.height - curY) / sz.height * 100)
			self.ScrollViewGame:scrollToPercentVertical(percent,0.05,false)
		end
	end
end

-- 注册全局事件
function clsGamePcddView:InitGlbEvents()
	g_EventMgr:AddListener(self, "APP_ENTER_FOREGROUND", function(thisObj)
		if utils.IsValidCCObject(self) then 
			proto.req_bet_game_state({gid=self.gameArg.gid}) 
			proto.req_bet_open_result({gid=self.gameArg.gid}) 
		end
	end)
	g_EventMgr:AddListener(self, "NET_STATE_CHANGE", function(thisObj)
		if PlatformHelper.isNetworkConnected() then
			proto.req_bet_game_state({gid=self.gameArg.gid}) 
			proto.req_bet_open_result({gid=self.gameArg.gid})
			if ClsGameMgr.GetInstance():GetWanfaData(self.gameArg.gid) then
				print("从缓存读取玩法")
				self:on_req_goucai_game_wanfa_list({data=ClsGameMgr.GetInstance():GetWanfaData(self.gameArg.gid)}, { gid=self.gameArg.gid })
			else
				proto.req_goucai_game_wanfa_list({ gid=self.gameArg.gid }, { gid=self.gameArg.gid })
			end
			proto.req_bet_open_result({gid=self.gameArg.gid})
		end
	end)
	g_EventMgr:AddListener(self, "fail_req_bet_game_state", function(this, recvdata, tArgs) 
		if tArgs and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmstate") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmstate", 1, function() proto.req_bet_game_state({gid=self.gameArg.gid}) end)
		end
	end)
	g_EventMgr:AddListener(self, "error_req_bet_game_state", function(this, recvdata, tArgs) 
		if tArgs and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmstate") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmstate", 1, function() proto.req_bet_game_state({gid=self.gameArg.gid}) end)
			if not self:HasTimer("tmerroropenrlt") then
				self:CreateAbsTimerDelay("tmerroropenrlt", 2, function() proto.req_bet_open_result({gid=self.gameArg.gid}) end)
			end
		end
	end)
	g_EventMgr:AddListener(self, "fail_req_goucai_game_wanfa_list", function(this, recvdata, tArgs) 
		if tArgs and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmwanfa") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmwanfa", 1, function() proto.req_goucai_game_wanfa_list({gid=self.gameArg.gid}, {gid=self.gameArg.gid}) end)
		end
	end)
	g_EventMgr:AddListener(self, "error_req_goucai_game_wanfa_list", function(this, recvdata, tArgs) 
		if tArgs and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmwanfa") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmwanfa", 1, function() proto.req_goucai_game_wanfa_list({gid=self.gameArg.gid}, {gid=self.gameArg.gid}) end)
		end
	end)
	g_EventMgr:AddListener(self, "fail_req_goucai_game_qiuhao_peilv_list", function(this, recvdata, tArgs) 
		if tArgs and self._selectedWanFa and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmpeilv") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmpeilv", 1, function() proto.req_goucai_game_qiuhao_peilv_list({ gid=self.gameArg.gid }, { gid=self.gameArg.gid, tid=tonumber(self._selectedWanFa.id) }) end)
		end
	end)
	g_EventMgr:AddListener(self, "error_req_goucai_game_qiuhao_peilv_list", function(this, recvdata, tArgs) 
		if tArgs and self._selectedWanFa and gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) and not self:HasTimer("tmpeilv") then 
			if not PlatformHelper.isNetworkConnected() then return end
			self:CreateAbsTimerDelay("tmpeilv", 1, function() proto.req_goucai_game_qiuhao_peilv_list({ gid=self.gameArg.gid }, { gid=self.gameArg.gid, tid=tonumber(self._selectedWanFa.id) }) end)
		end
	end)
	g_EventMgr:AddListener(self, "on_req_bet_game_state", self.on_req_bet_game_state, self)
	g_EventMgr:AddListener(self, "on_req_goucai_game_wanfa_list", self.on_req_goucai_game_wanfa_list, self)
	g_EventMgr:AddListener(self, "GAME_CUR_WANFA", self.OnCurWanFa, self)
	g_EventMgr:AddListener(self, "on_req_goucai_game_qiuhao_peilv_list", self.on_req_goucai_game_qiuhao_peilv_list, self)
	g_EventMgr:AddListener(self, "GAME_BILL_SUCC", function(thisObj, billId, oneBill, billPaper, gameObj)
		local betCount, totalCost = billPaper:GetTotalInfo(gameObj)
		if self.lblBetCount then self.lblBetCount:setString(betCount) end
		--询问是否清除旧的选中

		for _, BtnFeature in pairs(self._btnFeatureList) do
			if oneBill:GetBallIdx(BtnFeature._info.id) then
				self._billPaper:DelBall(BtnFeature._info.id)
				BtnFeature:SetSelectedQuiet(false)
			end
		end
		self:OnSelectBallChanged()
	end)
	g_EventMgr:AddListener(self, "GAME_ADD_BILLPAPER", function(thisObj, billPaper, gameObj)
		local betCount, totalCost = billPaper:GetTotalInfo(gameObj)
		if self.lblBetCount then self.lblBetCount:setString(betCount) end
	end)
	g_EventMgr:AddListener(self, "GAME_DEL_BILLPAPER", function(thisObj, gameObj)
		if self.lblBetCount then self.lblBetCount:setString(0) end
		self:ClearSelectedBalls()
		self.EditMoney:setString("")
	end)
	g_EventMgr:AddListener(self, "on_req_user_set_favorite", self.RefleshCollectBtn, self)
	g_EventMgr:AddListener(self, "on_req_user_get_favorite", self.RefleshCollectBtn, self)
	g_EventMgr:AddListener(self, "on_req_bet_open_result", self.on_req_bet_open_result, self)
end

function clsGamePcddView:CreateAnimation()
	local info = {
		number = "5,5,1",
		code_str = "1",
		color = "gray",
	}
	local spr = cc.Node:create()
	local tNumber = string.split(info.number, ",")
	local x0,y0 = self.NodeWait:getPositionX()-30, 0
	local sz = 48
	local curX = 0
	local ballSprs = {}
			
	local parent = spr
	for i, vvv in ipairs(tNumber) do
		local sprBall = utils.CreateSprite("uistu/common/gray_circle.png")
		parent:addChild(sprBall)
		sprBall:setPosition(x0+curX, y0)
		curX = curX + sz 
		sprBall:setColor(cc.c4b(250,0,0,255))
		if i == #tNumber then
			local sprAdd = utils.CreateSprite("uistu/common/equals.png")
			sprAdd:setPosition(x0+curX-7.5, y0)
			parent:addChild(sprAdd)
			curX = curX + 30
		else 
			local sprAdd = utils.CreateSprite("uistu/common/add.png")
			sprAdd:setPosition(x0+curX-7.5, y0)
			parent:addChild(sprAdd)
			curX = curX + 30
		end
		ballSprs[i] = sprBall
	end
	
	for i, vvv in ipairs(tNumber) do
		local x, y = ballSprs[i]:getPosition()
		local lblName = utils.CreateLabel(vvv, 24)
		lblName:setTextColor(cc.c3b(250,250,250))
		parent:addChild(lblName)
		lblName:setPosition(x, y)
		lblName:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(0.1),
				cc.CallFunc:create(function()
					lblName:setString( math.random(1,10) )
				end)
			)
		))
	end
				
	local sprBall = utils.CreateSprite("uistu/common/gray_circle.png")
	parent:addChild(sprBall)
	sprBall:setPosition(x0+curX, y0)
	curX = curX + sz 
	sprBall:setColor(const.GAME_LHC_COLOR[info.color] or const.GAME_LHC_COLOR.white)
	local lblName = utils.CreateLabel(info.code_str, 24)
	lblName:setTextColor(cc.c3b(250,250,250))
	parent:addChild(lblName)
	lblName:setPosition(sprBall:getPosition())
	lblName:runAction(cc.RepeatForever:create(
		cc.Sequence:create(
			cc.DelayTime:create(0.1),
			cc.CallFunc:create(function()
				lblName:setString( math.random(1,10) )
			end)
		)
	))
		
	return spr
	--[[
	local spr = ui.clsPicLabel.new()
	if spr then
		spr._idxAni = 0
		spr:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
				cc.DelayTime:create(0.05),
				cc.CallFunc:create(function()
					spr._idxAni = spr._idxAni + 1
					if spr._idxAni > 9 then spr._idxAni = 0 end
					spr:setString(string.format("%d,%d,%d",spr._idxAni,spr._idxAni,spr._idxAni))
				end)
			)
		))
	end
	return spr
	]]
end

function clsGamePcddView:RefleshWangqi()
	if not self._kithe or not self._preIssueData then return end
	local preKithe = tonumber(self._preIssueData.kj_issue)
	local curKithe = tonumber(self._kithe)
	local info = self._preIssueData
	local numtbl = string.split(info.number, ",") or {}
	
	local bWait = false
	if preKithe and curKithe and preKithe+2 == curKithe then
		bWait = true
	end
	
	if bWait then
		local waitKithe = curKithe - 1
		self.lblWangQi:setString(waitKithe.."期开奖号码")
		
		self.NodeLottery:removeAllChildren()
		self._diceList = nil
		
		if not self._effSaizi then
			--self._effSaizi = ui.clsPicLabel.new()  -- utils.CreateLabel("正在开奖", 28, const.COLOR.BLACK)
            self._effSaizi = self:CreateAnimation()
			self.NodeWait:addChild(self._effSaizi)
			self._effSaizi:setAnchorPoint(cc.p(0.5,0.5))
			--self._effSaizi:setString("正,在,开,奖")
		end
		
		if not self:HasTimer("ask_kaijiang") then
			self:CreateAbsTimerDelay("ask_kaijiang", gameutil.GetOpenResultInterval(self._remain_sec), function()
				proto.req_bet_open_result({gid=self.gameArg.gid})
			end)
		end
	else
		self.lblWangQi:setString(info.kj_issue .. "期开奖号码")
		
		self.NodeWait:removeAllChildren()
		self._effSaizi = nil
		
		if not self._diceList then
			local tNumber = string.split(info.number, ",")
			local x0,y0 = self.NodeLottery:getPositionX()-30, 0
			local sz = 48
			local curX = 0
			local ballSprs = {}
			self._diceList = ballSprs
			
			local parent = self.NodeLottery
			for i, vvv in ipairs(tNumber) do
				local sprBall = utils.CreateSprite("uistu/common/gray_circle.png")
				parent:addChild(sprBall)
				sprBall:setPosition(x0+curX, y0)
				curX = curX + sz 
				sprBall:setColor(cc.c4b(250,0,0,255))
				if i == #tNumber then
					local sprAdd = utils.CreateSprite("uistu/common/equals.png")
					sprAdd:setPosition(x0+curX-7.5, y0)
					parent:addChild(sprAdd)
					curX = curX + 30
				else 
					local sprAdd = utils.CreateSprite("uistu/common/add.png")
					sprAdd:setPosition(x0+curX-7.5, y0)
					parent:addChild(sprAdd)
					curX = curX + 30
				end
				ballSprs[i] = sprBall
			end
					
			for i, vvv in ipairs(tNumber) do
				local x, y = ballSprs[i]:getPosition()
				local lblName = utils.CreateLabel(vvv, 24)
				lblName:setTextColor(cc.c3b(250,250,250))
				parent:addChild(lblName)
				lblName:setPosition(x, y)
			end
				
			local sprBall = utils.CreateSprite("uistu/common/gray_circle.png")
			parent:addChild(sprBall)
			sprBall:setPosition(x0+curX, y0)
			curX = curX + sz 
			sprBall:setColor(const.GAME_LHC_COLOR[info.color] or const.GAME_LHC_COLOR.white)
			local lblName = utils.CreateLabel(info.code_str, 24)
			lblName:setTextColor(cc.c3b(250,250,250))
			parent:addChild(lblName)
			lblName:setPosition(sprBall:getPosition())
		end
	end
end

function clsGamePcddView:on_req_bet_open_result(recvdata,tArgs)
	local rows = recvdata and recvdata.data and recvdata.data.rows
	if not rows then return end
	if not gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) then return end
	local info = rows[1]
	self._preIssueData = info
	self:RefleshWangqi()
end

function clsGamePcddView:RefleshCollectBtn(recvdata, tArgs)
	logger.dump(tArgs)
	self.CheckBoxCollect:setSelected(ClsCollectMgr.GetInstance():HasCollect(self.gameArg.gid))
end

function clsGamePcddView:OnRemainSec(remainSec)
	if remainSec < 0 then remainSec = 0 end
	self._remain_sec = remainSec
	self.lblCountDown:setString( libtime.ChangeSToH(remainSec) )
end

function clsGamePcddView:StartCD(remainSec, gid)
	self:DestroyTimer("tmr_cd")
	self:DestroyTimer("tm_delay_state")
	self:OnRemainSec(remainSec)
	if remainSec > 0 then
		self:CreateAbsTimerLoop("tmr_cd", 1, function()
			remainSec = remainSec - 1
			if remainSec < 0 then remainSec = 0 end
			self:OnRemainSec(remainSec)
			if remainSec <= 0 then 
				proto.req_bet_game_state({gid=gid})
				proto.req_bet_open_result({gid=gid})
				return true 
			end
		end)
	else
		self:CreateAbsTimerDelay("tm_delay_state", 2, function()
			proto.req_bet_game_state({gid=gid})
			proto.req_bet_open_result({gid=gid})
		end)
	end
end

function clsGamePcddView:on_req_bet_game_state(recvdata,tArgs,bFromCache)
	local data = recvdata and recvdata.data and recvdata.data[1]
	if not data then return end
	if not gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) then return end
	self:DestroyTimer("tmstate")
	self._gameObj:SetGameStateInfo(data)
	
	if self._kithe and self._kithe ~= data.kithe and not bFromCache then
		local function callback(mnuId)
			if mnuId == 1 then
			--	self:ClearSelectedBalls()
			end
		end
		local tipStr = string.format( "%s期已截止#r当前期号#R%s#n#r投注时请注意期号", string.sub(self._kithe, -7,-1), string.sub(data.kithe, -7,-1) )
		ClsUIManager.GetInstance():PopConfirmDlg2("CFM_CLEAR_SELECT", "温馨提示", tipStr, callback)
        g_EventMgr:FireEvent("OVERTIPS")
        PlatformHelper.closeSystemKeyboard(self.EditMoney)
	end
	self._kithe = data.kithe
	
	self.lblCurrent:setString(data.kithe.."期投注截止")
	
	local remainSec = data.kithe_time_stamp - data.current_time_stamp
	
	self:StartCD(remainSec, data.gid)
	
	self:RefleshWangqi()
end

function clsGamePcddView:on_req_goucai_game_wanfa_list(recvdata,tArgs)
	local data = recvdata and recvdata.data 
	if not data then return end
	if not gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) then return end
	self:DestroyTimer("tmwanfa")
	self._wanfaList = data
	self._gameObj:SetWanFaList(data)
	self._gameObj:SetCurWanFa(self._wanfaList.play[1])
end

function clsGamePcddView:OnCurWanFa(info)
	print("选择游戏玩法")
	logger.dump(info)
	self._selectedWanFa = info
	self:RefleshBallsArea(nil)
	
	self.lblPlayType:setString(info.name or "")
	local sz = self.lblPlayType:getContentSize()
	local sz2 = self.BtnPlayType:getContentSize()
	self.BtnPlayType:setContentSize(sz.width*self.lblPlayType:getScale()+60, sz2.height)
	self.lblPlayType:setPositionX(10)
	self.sprPlayType:setPositionX(sz.width*self.lblPlayType:getScale()+60-10)
	
	local cached_peilv = ClsGameMgr.GetInstance():GetPeiLvData(self.gameArg.gid, tonumber(info.id))
	if cached_peilv then
		print("读取缓存中的赔率")
		local tArgs = { gid=self.gameArg.gid, _tUrlParams = { gid=self.gameArg.gid, tid=tonumber(info.id) } }
		self:on_req_goucai_game_qiuhao_peilv_list({data=cached_peilv}, tArgs)
	else
		proto.req_goucai_game_qiuhao_peilv_list({ gid=self.gameArg.gid }, { gid=self.gameArg.gid, tid=tonumber(info.id) })
	end
end

function clsGamePcddView:on_req_goucai_game_qiuhao_peilv_list(recvdata,tArgs)
	local data = recvdata and recvdata.data
	if not data then return end
	if not gameutil.IsSameGid(tArgs.gid, self.gameArg.gid) then return end
	self:DestroyTimer("tmpeilv")
	self._gameObj:SetCurPeiLvList(data)
	self:RefleshBallsArea(data)
end

function clsGamePcddView:RefleshBallsArea(data)
	self.ScrollViewGame:removeAllChildren()
	self._btnFeatureList = {}
	self._billPaper:Clear()
	if not data then
		self:OnSelectBallChanged()
		return
	end
	
	local tid = tostring( self._selectedWanFa.id )
	local infolist = data.balls_rate[tid].balls 

	--
	local cnt = #infolist
	local autoGrid = clsAutoGrid.new(720, self.ScrollViewGame:getContentSize().height, 20, 20)
	autoGrid:Begin()
	autoGrid:AddSpace(5)
	local objList = {}
	local btnWid, btnHei = 160,105
	for idx=1, cnt do 
		local ball = infolist[idx]
		local BtnFeature = self:CreateFeatureBtn(btnWid, btnHei, ball.name, self._gameObj:CalculatePeiLv(ball))
		table.insert(objList, BtnFeature)
		KE_SetParent(BtnFeature, self.ScrollViewGame)
		self._btnFeatureList[idx] = BtnFeature
		BtnFeature._info = ball
		
		BtnFeature:SetSelectCallback(function(sender, bSelected)
			logger.dump(ball)
			if bSelected then
				if self._billPaper:AddBall(self:GetCost(), ball, self._gameObj, true) then
					self:OnSelectBallChanged()
				else
					BtnFeature:SetSelectedQuiet(false)
				end
			else 
				self._billPaper:DelBall(ball.id)
				self:OnSelectBallChanged()
			end
		end)
	end
	autoGrid:AddRow(objList, 4, btnWid,btnHei, "left", 10)
	autoGrid:AddSpace(5)
	local totalHei = autoGrid:End()
	self.ScrollViewGame:setInnerContainerSize(cc.size(720,totalHei))
	
	self:OnSelectBallChanged()
end

function clsGamePcddView:CreateFeatureBtn(wid, hei, name,rate)
	return UIFactory.CreateRectangleButton(parent, wid, hei, name, rate)
end

function clsGamePcddView:OnSelectBallChanged()
	for _, BtnFeature in pairs(self._btnFeatureList) do
		if not BtnFeature:IsSelected() then
			if self._preSelect == BtnFeature then self._preSelect = nil end
		end
	end
	
	self._billPaper:SetCost(self:GetCost())
	local betCount, totalCost = self._billPaper:GetTotalInfo(self._gameObj)
	--self.lblBetInfo:setString( "共"..betCount.."注"..totalCost.."元" )
    self.lblBetInfo:setString(betCount)
    if betCount > 0 then
        self.BtnBasket:setTouchEnabled(true)
        --self.BtnBasket:setColor(cc.c3b(255,255,255))
    else
        self.BtnBasket:setTouchEnabled(false)
        --self.BtnBasket:setColor(cc.c3b(77,77,77))
    end
end

function clsGamePcddView:ClearSelectedBalls()
	for _, BtnFeature in pairs(self._btnFeatureList) do
		BtnFeature:SetSelectedQuiet(false)
	end
	self._billPaper:Clear()
	self:OnSelectBallChanged()
end

function clsGamePcddView:GetCost()
	local money = self.EditMoney:getString() or ""
	local pos = string.find(money, "%.")
	if pos then
		money = string.sub(money, 1, pos+1)
	end
	
	local cost = tonumber(money) or 0
	return cost
end
