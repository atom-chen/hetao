-------------------------
-- 投注明细
-------------------------
module("ui", package.seeall)

clsAgentBetDetail = class("clsAgentBetDetail", clsBaseUI)
g_EventMgr:RegisterEventType("Bet_Between_day")
local nBet_type = 0  --全部 0   已中奖 1    未中奖 5      待开奖 4
local PAGE_SIZE = 10
local cacheData = {}
local waitingPages = {}

local function ReqData(Username,Type, Between_day, Index)
	if cacheData[Username] and cacheData[Username].pageList and cacheData[Username].pageList[Type] and cacheData[Username].pageList[Type].timeList and cacheData[Username].pageList[Type].timeList[Between_day] and cacheData[Username].pageList[Type].timeList[Between_day].dataList and cacheData[Username].pageList[Type].timeList[Between_day].dataList[Index] then
		print("取缓存数据",Username, Type, Between_day, Index)
        return cacheData[Username].pageList[Type].timeList[Between_day].dataList[Index]
	end
	local waitKey = Username..Type..Between_day..Index 
	if waitingPages[waitKey] then
		print("等待数据返回中", Username, Type, Between_day, Index)
		KE_SetTimeout(60, function() waitingPages[waitKey] = nil end)
		return nil
	end
	waitingPages[waitKey] = true
	
	local params = {}
	params.type = Type
	params.between_day = Between_day
    params.index = Index
    params.username = Username
	proto.req_agent_bet_records(params, nil, function(recvdata)
		waitingPages[waitKey] = nil 
		local data = recvdata and recvdata.data
		if data then
			cacheData[Username] = cacheData[Username] or {}
            cacheData[Username].pageList = cacheData[Username].pageList or {}
            cacheData[Username].pageList[Type] = cacheData[Username].pageList[Type] or {}
            cacheData[Username].pageList[Type].timeList = cacheData[Username].pageList[Type].timeList or {}
            cacheData[Username].pageList[Type].timeList[Between_day] = cacheData[Username].pageList[Type].timeList[Between_day] or {}
            cacheData[Username].pageList[Type].timeList[Between_day].dataList = cacheData[Username].pageList[Type].timeList[Between_day].dataList or {}
            cacheData[Username].pageList[Type].timeList[Between_day].dataList[Index] = data
		end
	end)
end

function clsAgentBetDetail:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentBetDetail.csb")
    self.TextField_1 = utils.ReplaceTextField(self.TextField_1,"uistu/common/space.png","BLACK")

    self.ListView_1:setScrollBarEnabled(false)
    self.ListView_2:setScrollBarEnabled(false)
    self.ListView_3:setScrollBarEnabled(false)
    self.ListView_4:setScrollBarEnabled(false)
    self.ListView_1:setSwallowTouches(false)
    self.ListView_2:setSwallowTouches(false)
    self.ListView_3:setSwallowTouches(false)
    self.ListView_4:setSwallowTouches(false)
    
    self.ListView_1:setItemModel(self.ItemPanel)
    self.ListView_2:setItemModel(self.ItemPanel)
    self.ListView_3:setItemModel(self.ItemPanel)
    self.ListView_4:setItemModel(self.ItemPanel)
    
    waitingPages = {}
    cacheData = {}

    self.Between_day = 0
    self.index = 0
    self.username = ""
	self:InitUiEvents()
	self:InitGlbEvents()
	
    g_EventMgr:AddListener(self,"on_req_agent_bet_records",self.RefleshPage,self)
    g_EventMgr:AddListener(self,"Bet_Between_day",function(this,data)
        self.Between_day = data.between_day
        self.index = data.index
        if self.Between_day == 0 then
            self.Text_32:setString("今天")
        elseif self.Between_day == 1 then
            self.Text_32:setString("昨天")
        elseif self.Between_day == 7 then
            self.Text_32:setString("七天")
        end
        if cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[data.type] and cacheData[self.username].pageList[data.type].timeList and cacheData[self.username].pageList[data.type].timeList[data.between_day] and cacheData[self.username].pageList[data.type].timeList[data.between_day].dataList and cacheData[self.username].pageList[data.type].timeList[data.between_day].dataList[data.index] then
        --if cacheData[data.type] and cacheData[data.type].pageList and cacheData[data.type].pageList[data.between_day] and cacheData[data.type].pageList[data.between_day].dataList and cacheData[data.type].pageList[data.between_day].dataList[data.index] then
            self:RefleshPage(true)
        else
            ReqData(self.username,data.type,data.between_day,data.index)
        end
        
    end,self)
    g_EventMgr:AddListener(self,"on_req_agent_bet_detail",function()
        ClsUIManager.GetInstance():ShowPanel("clsAgentBetList")
    end,self)
    self:SwitchTo(0)
    local tcLayer = cc.Node:create()
	self:addChild(tcLayer)
	local function onTouchBegan(touch, event)
		self._beginX = touch:getLocation().x
		self._beginY = touch:getLocation().y
		return true
	end
	local function onTouchMoved(touch, event)

	end
	local function onTouchEnded(touch, event)
		self._deltaX = touch:getLocation().x - self._beginX
		if math.abs(touch:getLocation().y - self._beginY) < 50 then
			if self._deltaX >= 8 then
				self:SwitchTo(self._curPage - 1)
			elseif self._deltaX <= -8 then
				self:SwitchTo(self._curPage + 1)
			end
		end
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchMoved, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchEnded, cc.Handler.EVENT_TOUCH_ENDED)
	tcLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, tcLayer)
	listener:setSwallowTouches(false)
end

function clsAgentBetDetail:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local w = self.PanelPages:getContentSize().width
	local h = self.PanelPages:getContentSize().height + GAME_CONFIG.HEIGHT_DIFF
	self.PanelPages:setContentSize(w, h)
	self.Panel_1:setContentSize(w, h)
	self.Panel_2:setContentSize(w, h)
	self.Panel_3:setContentSize(w, h)
	self.Panel_4:setContentSize(w, h)
	self.ListView_1:setContentSize(w, h)
	self.ListView_2:setContentSize(w, h)
	self.ListView_3:setContentSize(w, h)
	self.ListView_4:setContentSize(w, h)
	self.PanelPages:setPositionY(0)
end

function clsAgentBetDetail:SwitchTo(nPage)
    self.index = 0
    --self.Between_day = 0
    if nPage < 0 then nPage = 0 end
    if nPage > 3 then nPage = 3 end
    if nPage == 0 then
        nBet_type = 0
    elseif nPage == 1 then
        nBet_type = 1
    elseif nPage == 2 then
        nBet_type = 5
    elseif nPage == 3 then
        nBet_type = 4
    end
    self._curPage = nPage
    self:OnTurn2Page(nPage)
end

function clsAgentBetDetail:OnTurn2Page(nPage)
    local highColor = cc.c3b(255,0,0)
    local normalColor = cc.c3b(0,0,0)
    self.Button_9:setTitleColor(nPage == 0 and highColor or normalColor)
    self.Button_9_0:setTitleColor(nPage == 1 and highColor or normalColor)
    self.Button_9_1:setTitleColor(nPage == 2 and highColor or normalColor)
    self.Button_9_2:setTitleColor(nPage == 3 and highColor or normalColor)
    for i=1,4 do
		self["ListView_"..i]:stopAutoScroll()
		self["ListView_"..i]:forceDoLayout()
	end
    local dstX = -self.PanelPages:getContentSize().width * nPage
    self.PanelPages:stopAllActions()
    local useTime = math.abs(self.PanelPages:getPositionX()-dstX) / 2000
    self.PanelPages:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.PanelPages:getPositionY())))

    self:RefleshPage()
    ReqData(self.username,nBet_type,self.Between_day,self.index)
end

function clsAgentBetDetail:RefleshPage(needFlush)
	if not self._curPage then return end

	local listWnd 
    if self._curPage == 0 then
		listWnd = self.ListView_1
	elseif self._curPage == 1 then
		listWnd = self.ListView_2
	elseif self._curPage == 2 then
		listWnd = self.ListView_3
	elseif self._curPage == 3 then
		listWnd = self.ListView_4
	end
    if self.Between_day == 0 then
        self.Text_32:setString("今天")
    elseif self.Between_day == 1 then
        self.Text_32:setString("昨天")
    elseif self.Between_day == 7 then
        self.Text_32:setString("七天")
    end
	local data = cacheData and cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[nBet_type] and cacheData[self.username].pageList[nBet_type].timeList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day] and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList 
	if not data then 
        self:ClearPage(nBet_type)
        gameutil.MarkAllLoaded(listWnd)
        return 
    end

    dump(data)
    
    gameutil.UnMarkAllLoaded(listWnd)
    
	listWnd:stopAutoScroll()
	local toppestItem = listWnd:getBottommostItemInCurrentView()
	local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
	
	local curIndex = 0
    local oldLen = #listWnd:getItems()
    print("-------------- old len", oldLen)
    
    local curLen = 0
	for i=0,self.index,10 do
		if data[i] then
			for _, info in ipairs(data[i]) do
				local item = listWnd:getItem(curIndex)
				if utils.IsValidCCObject(item) then
					utils.getNamedNodes(item)
					self:RefreshItem(item, info)
				else
					listWnd:pushBackDefaultItem()
                    item = listWnd:getItem(curIndex)
					utils.getNamedNodes(item)
					self:RefreshItem(item, info)
					item:setSwallowTouches(false)
				end
                curIndex = curIndex + 1 
                curLen = curLen + 1
			end
		else
			break
		end
	end

    for i=oldLen, curLen+1, -1 do
        listWnd:removeItem(i-1)
    end
	
	if #listWnd:getItems()%PAGE_SIZE ~= 0 or self.index > #listWnd:getItems() then
		gameutil.MarkAllLoaded(listWnd)
	end
	if toppestIdx and toppestIdx >= 0 and not needFlush then
		listWnd:stopAutoScroll()
		listWnd:forceDoLayout()
		listWnd:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	end 
end

function clsAgentBetDetail:dtor()
	
end

--注册控件事件
function clsAgentBetDetail:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_9, function() self:SwitchTo(0) end)
    utils.RegClickEvent(self.Button_9_0, function() self:SwitchTo(1) end)
    utils.RegClickEvent(self.Button_9_1, function() self:SwitchTo(2) end)
    utils.RegClickEvent(self.Button_9_2, function() self:SwitchTo(3) end)
    utils.RegClickEvent(self.Button_2, function()
        ClsAgentDataMgr.GetInstance():SaveBetType(nBet_type)
        ClsAgentDataMgr.GetInstance():SaveType(3)
        ClsUIManager.GetInstance():ShowPopWnd("clsAgentDataSelect")
    end)
    utils.RegClickEvent(self.Button_8,function()
        local name = self.TextField_1:getText()
        self.username = name
        ReqData(self.username,nBet_type,self.Between_day,self.index)
    end)
     self.ListView_1:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView_1:getInnerContainerPosition().y > 0 then
        	local items = self.ListView_1:getItems()
        	local cnt = #items
        	if cnt%10 == 0 then
                self.index = self.index + 10
                if cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[nBet_type] and cacheData[self.username].pageList[nBet_type].timeList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day] and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
                else
                    ReqData(self.username, 0, self.Between_day, self.index)
                end
		    end
    	end
    end )
    self.ListView_2:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView_2:getInnerContainerPosition().y > 0 then
        	local items = self.ListView_2:getItems()
        	local cnt = #items
        	if cnt%10 == 0 then
                self.index = self.index + 10
                if cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[nBet_type] and cacheData[self.username].pageList[nBet_type].timeList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day] and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
                else
                    ReqData(self.username, 1, self.Between_day, self.index)
                end
		    end
    	end
    end )
    self.ListView_3:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView_3:getInnerContainerPosition().y > 0 then
        	local items = self.ListView_3:getItems()
        	local cnt = #items
        	if cnt%10 == 0 then
                self.index = self.index + 10
                if cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[nBet_type] and cacheData[self.username].pageList[nBet_type].timeList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day] and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
                else
                    ReqData(self.username, 5, self.Between_day, self.index)
                end
		    end
    	end
    end )
    self.ListView_4:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView_4:getInnerContainerPosition().y > 0 then
        	local items = self.ListView_4:getItems()
        	local cnt = #items
        	if cnt%10 == 0 then
                self.index = self.index + 10
                if cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[nBet_type] and cacheData[self.username].pageList[nBet_type].timeList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day] and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList and cacheData[self.username].pageList[nBet_type].timeList[self.Between_day].dataList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
                else
                    ReqData(self.username, 4, self.Between_day, self.index)
                end
		    end
    	end
    end )
end

-- 注册全局事件
function clsAgentBetDetail:InitGlbEvents()
	
end

function clsAgentBetDetail:RefreshItem(item,info)
	if not item.gamename then assert(utils.IsValidCCObject(item)) end
    item:getChildByName("gamename"):setString(info.game)
    item.money:setString(info.price_sum)
    item.time:setString(os.date("%y-%m-%d %H:%M:%S",info.created))
    local _status
    if info.status == "1" then
        status = "已中奖"
    elseif info.status == "2" then
        status = "和值"
    elseif info.status == "3" then
        status = "撤单"
    elseif info.status == "4" then
        status = "待开奖"
    elseif info.status == "5" then
        status = "未中奖"
    end
    item.status:setString(status)
    utils.RegClickEvent(item,function()
        ClsAgentDataMgr.GetInstance():SaveBetNum(info.order_num)
        proto.req_agent_bet_detail({order_num = info.order_num})
        --ClsUIManager.GetInstance():ShowPanel("clsAgentBetList")
    end)
end

function clsAgentBetDetail:ClearPage(Type)
    if Type == 0 then
        self.ListView_1:removeAllChildren()
    elseif Type == 1 then
        self.ListView_2:removeAllChildren()
    elseif Type == 5 then
        self.ListView_3:removeAllChildren()
    elseif Type == 4 then
        self.ListView_4:removeAllChildren()
    end
end