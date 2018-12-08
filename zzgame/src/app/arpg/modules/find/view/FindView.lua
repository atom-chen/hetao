module("ui", package.seeall)

local CELL_HEI = 120

clsFindView = class("clsFindView", clsBaseUI)

function clsFindView:ctor(parent)
    clsBaseUI.ctor(self, parent, "uistu/FindView.csb")
    self.ContWnd = self.AreaAuto
    self:InitListToday()
    self:InitListYesToday()
    self:InitUiEvents()
    g_EventMgr:AddListener(self, "on_req_award_today", self.on_req_award_today, self)
    g_EventMgr:AddListener(self, "on_req_award_yestoday", self.on_req_award_yestoday, self)
    self:SwitchPage("1")
    
    --昨日数据不必实时刷新
    if clsFindMgr.GetInstance():GetYesterRewardData() then
        self:on_req_award_yestoday()
    else
        proto.req_award_yestoday()
    end
end

function clsFindView:dtor()
	if self._needClear then
		clsFindMgr.GetInstance():ClearTodayRewardData()
	end
end

function clsFindView:InitUiEvents()
    utils.RegClickEvent(self.TodayBtn,function()
        self:SwitchPage("1")
    end)
    utils.RegClickEvent(self.YesterBtn,function()
        self:SwitchPage("2")
    end)
end

function clsFindView:SwitchPage(pageId)
	self.LeftorRight = pageId

    if self.LeftorRight == "1" then  --今日
        self.TodayBtn:setColor(cc.c3b(220,59,64))
        self.Todaylabel:setTextColor(cc.c3b(255,255,255))
        self.YesterBtn:setColor(cc.c3b(255,255,255))
        self.Yesterlabel:setTextColor(cc.c3b(0,0,0))
        --
        if clsFindMgr.GetInstance():GetTodayRewardData() then
        	self:on_req_award_today()
        else
        	proto.req_award_today()
        end
    elseif self.LeftorRight == "2" then	--昨日
        self.TodayBtn:setColor(cc.c3b(255,255,255))
        self.Todaylabel:setTextColor(cc.c3b(0,0,0))
        self.YesterBtn:setColor(cc.c3b(220,59,64))
        self.Yesterlabel:setTextColor(cc.c3b(255,255,255))
        --昨日数据不必实时刷新
        if clsFindMgr.GetInstance():GetYesterRewardData() then
        	self:on_req_award_yestoday()
        else
        	self._refreshedToday = false
        	proto.req_award_yestoday()
        end
    else 
    	assert(false)
    end
end

function clsFindView:InitListToday()
	local sz = self.ContWnd:getContentSize()
	self.listToday = clsCompList.new(self.ContWnd, ccui.ScrollViewDir.vertical, sz.width, sz.height, sz.width, CELL_HEI)
	self.listToday:setScrollBarEnabled(false)
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local node = cc.CSLoader:createNode("uistu/RewardInfo.csb")
		local curBtn = node:getChildByName("ListItem")
		utils.getNamedNodes(curBtn)
		utils.AdaptCsbFonts(curBtn)
    	curBtn.username:setString(info.username or "")
    	curBtn.gamename:setString("在"..info.game)
        curBtn.gamename:setPositionX(curBtn.username:getPositionX()+curBtn.username:getContentSize().width/g_ContentScaleFactor+10)
    	curBtn.money:setString("￥" .. info.price_sum)
    	curBtn.money:setPositionX(curBtn.Text_3:getPositionX()+curBtn.Text_3:getContentSize().width/g_ContentScaleFactor+20)
    	if info.img == nil or info.img == 0 or info.img == "" or info.img == "0" then
            curBtn.userimage:SetHeadImg(self:autoHead(info.uid))
        else
            curBtn.userimage:SetHeadImg(info.img)
        end
		
		utils.RegClickEvent(curBtn, function() 
			ClsUIManager.GetInstance():ShowPanel("clsPlayerInfoView"):SetParam(info.uid, self.LeftorRight)
		end)
		
		return curBtn
	end
	self.listToday:SetCellCreator(createFunc)
end
function clsFindView:InitListYesToday()
	local sz = self.ContWnd:getContentSize()
	self.ListYesToday = clsCompList.new(self.ContWnd, ccui.ScrollViewDir.vertical, sz.width, sz.height, sz.width, CELL_HEI)
	self.ListYesToday:setScrollBarEnabled(false)
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		local i = CellObj:GetCellId()
		local node = cc.CSLoader:createNode("uistu/RewardInfo.csb")
		local curBtn = node:getChildByName("ListItem")
		
		utils.getNamedNodes(curBtn)
		utils.AdaptCsbFonts(curBtn)
    	curBtn.username:setString("账号昵称：")
        curBtn.username:setTextColor(cc.c3b(0,0,0))
    	curBtn.gamename:setString(info.username or "")
        curBtn.gamename:setTextColor(cc.c3b(139,105,20))
        --curBtn.Text_3:setPositionX(305)
    	curBtn.money:setString("￥" .. info.lucky_price)
    	curBtn.Text_3:setString("昨日奖金：")
        curBtn.gamename:setPositionX(curBtn.Text_3:getPositionX()+curBtn.Text_3:getContentSize().width/g_ContentScaleFactor+10)
    	--curBtn.Image_1:setVisible(false)
    	if info.img == nil or info.img == 0 or info.img == "" or info.img == "0" then
            curBtn.userimage:SetHeadImg(self:autoHead(info.uid))
        else
            curBtn.userimage:SetHeadImg(info.img)
        end
        curBtn.Image_3:setVisible(false)
		
		if i<=3 then 
			local sprBg = utils.CreateSprite("uistu/common/ic_lucky_money_".. i ..".png")
			curBtn:addChild(sprBg)
			sprBg:setPosition(619, 70)
		end
		local lblRank = utils.CreateLabel(i, 24)
		curBtn:addChild(lblRank)
		lblRank:setPosition(619,70)
		if i>3 then lblRank:setTextColor(const.COLOR.BLACK) end
		
        curBtn.money:setPositionX(curBtn.Text_3:getPositionX()+curBtn.Text_3:getContentSize().width/g_ContentScaleFactor+10)
		
		utils.RegClickEvent(curBtn, function() 
			--ClsUIManager.GetInstance():ShowPanel("clsPlayerInfoView"):SetParam(info.uid, self.LeftorRight)
		end)
		
		return curBtn
	end
	self.ListYesToday:SetCellCreator(createFunc)
end

function clsFindView:on_req_award_today(recvdata)
	if self.LeftorRight ~= "1" then return end
	if not self.listToday then return end
	self.listToday:setVisible(true)
	self.ListYesToday:setVisible(false)
	
    local awardinfo = clsFindMgr.GetInstance():GetTodayRewardData()
    if not awardinfo then print("----- no awardinfo") return end
    if self._refreshedToday then print("----- has _refreshedToday") return end
    self._refreshedToday = true
    print("------- refresh TodayBtn", #awardinfo)
    local listWnd = self.listToday
	local preCnt = listWnd:GetCellCount()
	local prePos = listWnd:getInnerContainerPosition()
	listWnd:RemoveAll()
	self:DestroyTimer("todaylist")
    local count = #awardinfo
	for i = math.max(1,count-9), count do 
		listWnd:Insert(awardinfo[i])
	end
	listWnd:ForceReLayout()
	local curCnt = listWnd:GetCellCount()
	if preCnt == curCnt then
		listWnd:setInnerContainerPosition(prePos)
	end
	
	if count > 10 then
		local fix = count-10
		self:CreateAbsTimerLoop("todaylist", 2, function()
			if fix < 1 then 
				self._needClear = true
				return true 
			end
			if listWnd:isVisible() then
				local prePos = listWnd:getInnerContainerPosition()
				listWnd:Insert(awardinfo[fix], nil, 1)
				listWnd:ForceReLayout()
				if listWnd:getInnerContainerSize().height > listWnd:getContentSize().height then
					listWnd:setInnerContainerPosition(cc.p(prePos.x, prePos.y-CELL_HEI))
				end
				fix = fix - 1
				if fix < 1 then 
					self._needClear = true
					return true 
				end
			end
		end)
	end
end

function clsFindView:on_req_award_yestoday(recvdata)
	if self.LeftorRight ~= "2" then return end
	if not self.ListYesToday then return end
	self.listToday:setVisible(false)
	self.ListYesToday:setVisible(true)
	
    local awardinfo = clsFindMgr.GetInstance():GetYesterRewardData()
    if not awardinfo then return end
    if self._refreshedYestoday then return end
    self._refreshedYestoday = true
    
    local listWnd = self.ListYesToday
	local preCnt = listWnd:GetCellCount()
	local prePos = listWnd:getInnerContainerPosition()
	listWnd:RemoveAll()
	for i, info in ipairs(awardinfo) do
		listWnd:Insert(info, i)
	end
	listWnd:ForceReLayout()
	local curCnt = listWnd:GetCellCount()
	if preCnt == curCnt then
		listWnd:setInnerContainerPosition(prePos)
	end
end
Head = {
    "uistu/wnds/default0.png",
    "uistu/wnds/default1.png",
    "uistu/wnds/default2.png",
    "uistu/wnds/default3.png",
    "uistu/wnds/default4.png",
    "uistu/wnds/default5.png",
    "uistu/wnds/default6.png",
    "uistu/wnds/default7.png",
    "uistu/wnds/default8.png",
    "uistu/wnds/default9.png",
}
function clsFindView:autoHead(id)
    local i = tonumber(id)%10
    return Head[i+1]
end