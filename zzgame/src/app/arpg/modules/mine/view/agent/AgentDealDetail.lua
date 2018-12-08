-------------------------
-- 交易明细
-------------------------
module("ui", package.seeall)

clsAgentDealDetail = class("clsAgentDealDetail", clsBaseUI)
g_EventMgr:RegisterEventType("Between_day")
local Trading_type = -1
local PAGE_SIZE = 10
local cacheData = {}
local waitingPages = {}
local function ReqData(Username, Type, Between_day, Index)
	if cacheData[Username] and cacheData[Username].pageList and cacheData[Username].pageList[Type] and cacheData[Username].pageList[Type].timeList and cacheData[Username].pageList[Type].timeList[Between_day] and cacheData[Username].pageList[Type].timeList[Between_day].dataList and cacheData[Username].pageList[Type].timeList[Between_day].dataList[Index] then
		print("取缓存数据",Username, Type, Between_day, Index)
		return cacheData[Username].pageList[Type].timeList[Between_day].dataList[Index]
	end
	local waitKey = Username..Type..Between_day..Index
	if waitingPages[waitKey] then
		print("等待数据返回中", Type, Between_day, Index)
		KE_SetTimeout(60, function() waitingPages[waitKey] = nil end)
		return nil
	end
	waitingPages[waitKey] = true
	

	local params = {}
	params.type = ""
	params.index = tostring(Index)
    params.between_day = tostring(Between_day)
    params.username = Username
    if Type == 0 then
	    proto.req_agent_transaction_detail(params, nil, function(recvdata)
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
    elseif Type == 1 then
        proto.req_agent_withdraw_records(params, nil, function(recvdata)
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
    elseif Type == 2 then
        proto.req_agent_charge_records(params, nil, function(recvdata)
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
end
function clsAgentDealDetail:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentDealDetail.csb")
    self.TextField_1 = utils.ReplaceTextField(self.TextField_1,"uistu/common/space.png","BLACK")
    self.ListView_1:setScrollBarEnabled(false)
    self.ListView_2:setScrollBarEnabled(false)
    self.ListView_3:setScrollBarEnabled(false)
    self.ListView_1:setSwallowTouches(false)
    self.ListView_2:setSwallowTouches(false)
    self.ListView_3:setSwallowTouches(false)
    
	cacheData = {}
	waitingPages = {}

	self:InitUiEvents()
	self:InitGlbEvents()
    self.Between_day = 0
    self.index = 0
    self.username = ""
	
    g_EventMgr:AddListener(self,"on_req_agent_transaction_detail",self.RefleshPage,self)
    g_EventMgr:AddListener(self,"on_req_agent_withdraw_records",self.RefleshPage,self)
    g_EventMgr:AddListener(self,"on_req_agent_charge_records",self.RefleshPage,self)
    g_EventMgr:AddListener(self,"Between_day",function(this,data)
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
            self:RefleshPage()
        else
            ReqData(self.username, data.type,data.between_day,data.index)
        end
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

function clsAgentDealDetail:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local w = self.PanelPages:getContentSize().width
	local h = self.PanelPages:getContentSize().height + GAME_CONFIG.HEIGHT_DIFF
	self.PanelPages:setContentSize(w, h)
	self.Panel_1:setContentSize(w, h)
	self.Panel_2:setContentSize(w, h)
	self.Panel_3:setContentSize(w, h)
	self.ListView_1:setContentSize(w, h)
	self.ListView_2:setContentSize(w, h)
	self.ListView_3:setContentSize(w, h)
	self.PanelPages:setPositionY(0)
end

function clsAgentDealDetail:SwitchTo(npage)
    self.index = 0
    --self.Between_day = 0
    if npage < 0 then npage = 0 end
    if npage > 2 then npage = 2 end
    if npage == 0 then
        Trading_type = 0
    elseif npage == 1 then
        Trading_type = 1
    elseif npage == 2 then
        Trading_type = 2
    end
    self._curPage = npage
    self:OnTurn2Page(npage)
end

function clsAgentDealDetail:OnTurn2Page(npage)
    local highColor = cc.c3b(255,0,0)
    local normalColor = cc.c3b(0,0,0)
    self.Button_1:setTitleColor(npage == 0 and highColor or normalColor)
    self.Button_3:setTitleColor(npage == 1 and highColor or normalColor)
    self.Button_4:setTitleColor(npage == 2 and highColor or normalColor)
    for i=1,3 do
		self["ListView_"..i]:stopAutoScroll()
		self["ListView_"..i]:forceDoLayout()
	end
    local dstX = -self.PanelPages:getContentSize().width * npage
    self.PanelPages:stopAllActions()
    local useTime = math.abs(self.PanelPages:getPositionX()-dstX) / 2000
    self.PanelPages:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.PanelPages:getPositionY())))
    self:RefleshPage()
    
	ReqData(self.username, self._curPage,self.Between_day,self.index)
end

function clsAgentDealDetail:RefleshPage()
    if not self._curPage then return end
    local thedata = cacheData and cacheData[self.username] and cacheData[self.username].pageList and cacheData[self.username].pageList[self._curPage] and cacheData[self.username].pageList[self._curPage].timeList and cacheData[self.username].pageList[self._curPage].timeList[self.Between_day] and cacheData[self.username].pageList[self._curPage].timeList[self.Between_day].dataList
    if self.Between_day == 0 then
        self.Text_32:setString("今天")
    elseif self.Between_day == 1 then
        self.Text_32:setString("昨天")
    elseif self.Between_day == 7 then
        self.Text_32:setString("七天")
    end
    
    local npage = self._curPage
    local ListWnd
    if npage == 0 then
    	ListWnd = self.ListView_1
    elseif npage == 1 then
        ListWnd = self.ListView_2
    elseif npage == 2 then
        ListWnd = self.ListView_3
    end
    
    if not thedata then
        self:ClearPage(self._curPage)
        gameutil.MarkAllLoaded(ListWnd)
        return
    end
    
    gameutil.UnMarkAllLoaded(ListWnd)
	local lastlen = #ListWnd:getItems()
    local curlen = 0
    if npage == 0 then
        ListWnd = self.ListView_1
        
        --self.ListView_1:removeAllChildren()
        self.ListView_1:setItemModel(self.item)
        local toppestItem = self.ListView_1:getBottommostItemInCurrentView()
        local toppestIdx = toppestItem and self.ListView_1:getIndex(toppestItem)
        local itemindex = 0
        for i = 0,self.index,10 do
            thedata = cacheData[self.username].pageList[self._curPage].timeList[self.Between_day].dataList[i]
            print("self._curpage:"..self._curPage.."    self.Between_day:"..self.Between_day.."     index:"..i)
            if not thedata then
                break
            end
            for _,info in ipairs(thedata) do
                local itemnode = self.ListView_1:getItem(itemindex)
                if itemnode then
                    self:RefreshItem_all(itemnode,info)
                else
                    self.ListView_1:pushBackDefaultItem()
                    itemnode = self.ListView_1:getItem(itemindex)
                    self:RefreshItem_all(itemnode,info)
                end
                
                itemindex = itemindex + 1
                curlen = curlen + 1
            end
        end
        for i = lastlen,curlen + 1,-1 do
            ListWnd:removeItem(i - 1)
        end
        if toppestIdx and toppestIdx >= 0 then
		    self.ListView_1:stopAutoScroll()
		    self.ListView_1:forceDoLayout()
		    self.ListView_1:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	    end 
    elseif npage == 1 then
        ListWnd = self.ListView_2
        self.ListView_2:setItemModel(self.item)
        local toppestItem = self.ListView_2:getBottommostItemInCurrentView()
        local toppestIdx = toppestItem and self.ListView_2:getIndex(toppestItem)
        local itemindex = 0
        for i = 0,self.index,10 do
            thedata = cacheData[self.username].pageList[self._curPage].timeList[self.Between_day].dataList[i]
            print("self._curpage:"..self._curPage.."    self.Between_day:"..self.Between_day.."     index:"..i)
            if not thedata then
                break
            end
            for _,info in ipairs(thedata) do
                local itemnode = self.ListView_2:getItem(itemindex)
                if itemnode then
                    self:RefreshItem_withdraw(itemnode,info)
                else
                    self.ListView_2:pushBackDefaultItem()
                    itemnode = self.ListView_2:getItem(itemindex)
                    self:RefreshItem_withdraw(itemnode,info)
                end
                
                itemindex = itemindex + 1
                curlen = curlen +1
            end
        end
        for i = lastlen,curlen + 1,-1 do
            ListWnd:removeItem(i - 1)
        end
        if toppestIdx and toppestIdx >= 0 then
		    self.ListView_2:stopAutoScroll()
		    self.ListView_2:forceDoLayout()
		    self.ListView_2:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	    end 
    elseif npage == 2 then
        ListWnd = self.ListView_3
        self.ListView_3:setItemModel(self.item)
        local toppestItem = self.ListView_3:getBottommostItemInCurrentView()
        local toppestIdx = toppestItem and self.ListView_3:getIndex(toppestItem)
        local itemindex = 0
        for i = 0,self.index,10 do
            thedata = cacheData[self.username].pageList[self._curPage].timeList[self.Between_day].dataList[i]
            print("self._curpage:"..self._curPage.."    self.Between_day:"..self.Between_day.."     index:"..i)
            if not thedata then
                break
            end
            for _,info in ipairs(thedata) do
                local itemnode = self.ListView_3:getItem(itemindex)
                if itemnode then
                    self:RefreshItem_recharge(itemnode,info)
                else
                    self.ListView_3:pushBackDefaultItem()
                    itemnode = self.ListView_3:getItem(itemindex)
                    self:RefreshItem_recharge(itemnode,info)
                end
                itemindex = itemindex + 1
                curlen = curlen + 1
            end
        end
        for i = lastlen,curlen + 1,-1 do
            ListWnd:removeItem(i - 1)
        end
        if toppestIdx and toppestIdx >= 0 then
		    self.ListView_3:stopAutoScroll()
		    self.ListView_3:forceDoLayout()
		    self.ListView_3:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	    end 
    end
    if #ListWnd:getItems()%10 ~= 0 or self.index > #ListWnd:getItems()then
        gameutil.MarkAllLoaded(ListWnd)
    end 
    
end
function clsAgentDealDetail:dtor()
	
end

--注册控件事件
function clsAgentDealDetail:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_1, function() self:SwitchTo(0) end)
    utils.RegClickEvent(self.Button_3, function() self:SwitchTo(1) end)
    utils.RegClickEvent(self.Button_4, function() self:SwitchTo(2) end)
    self.TextField_1:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "ended" then
            self.username = self.TextField_1:getString()
        elseif evenName == "return" then
            self.username = self.TextField_1:getString()
        end
    end)
    utils.RegClickEvent(self.Button_2, function()
        self.username = self.TextField_1:getText()
        ClsAgentDataMgr.GetInstance():SaveType(4)
        ClsAgentDataMgr.GetInstance():SaveTradingType(Trading_type)
        ClsUIManager.GetInstance():ShowPopWnd("clsAgentDataSelect")
    end)
    utils.RegClickEvent(self.Button_5,function()
        self.username = self.TextField_1:getText()
        if self.username == "" then
            utils.TellMe("当前搜索条件为空，出现的是所有下级")
        end
        self:RefleshPage()
        ReqData(self.username, self._curPage, self.Between_day, self.index)
    end)
    self.ListView_1:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView_1:getInnerContainerPosition().y > 0 then
        	local items = self.ListView_1:getItems()
            print("有多少条啊啊啊啊啊："..#items)
        	local cnt = #items
        	if cnt%10 == 0 then
                self.index = self.index + 10
	        	if cacheData[self._curPage] and cacheData[self._curPage].total and cnt >= cacheData[self._curPage].total then
	        	else
		        	if cacheData[self._curPage] and cacheData[self._curPage].pageList and cacheData[self._curPage].pageList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
		        	else
		        		ReqData(self.username, 0, self.Between_day, self.index)
		        	end
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
	        	if cacheData[self._curPage] and cacheData[self._curPage].total and cnt >= cacheData[self._curPage].total then
	        	else
		        	if cacheData[self._curPage] and cacheData[self._curPage].pageList and cacheData[self._curPage].pageList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
		        	else
		        		ReqData(self.username, 1, self.Between_day, self.index)
		        	end
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
	        	if cacheData[self._curPage] and cacheData[self._curPage].total and cnt >= cacheData[self._curPage].total then
	        	else
		        	if cacheData[self._curPage] and cacheData[self._curPage].pageList and cacheData[self._curPage].pageList[self.index] then
		        		--logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
		        	else
		        		ReqData(self.username, 2, self.Between_day, self.index)
		        	end
		        end
		    end
    	end
    end )
end

-- 注册全局事件
function clsAgentDealDetail:InitGlbEvents()
	
end

function clsAgentDealDetail:RefreshItem_all(itemnode,info)
    itemnode:getChildByName("username"):setString(info.username)
    itemnode:getChildByName("time"):setString(os.date( "%Y-%m-%d %H:%M:%S", tonumber(info.addtime) ) or "")
    itemnode:getChildByName("price_num"):setString(info.amount)
    if tonumber(info.amount) < 0 then
        itemnode:getChildByName("price_num"):setTextColor(cc.c3b(35,144,104))
    end
    itemnode:getChildByName("status"):setString(info.type)
end

function clsAgentDealDetail:RefreshItem_withdraw(itemnode,info)
    itemnode:getChildByName("username"):setString(info.username)
    itemnode:getChildByName("time"):setString(os.date( "%Y-%m-%d %H:%M:%S", tonumber(info.addtime) ) or "")
    itemnode:getChildByName("price_num"):setString(info.price)
    local status
    if info.status == "1" then
        status = "处理中"
    elseif info.status == "2" then
        status = "提现成功"
    elseif info.status == "3" then
        status = "提现失败"
    end
    itemnode:getChildByName("status"):setString(status)
end

function clsAgentDealDetail:RefreshItem_recharge(itemnode,info)
    itemnode:getChildByName("username"):setString(info.username)
    itemnode:getChildByName("time"):setString(os.date( "%Y/%m/%d %H:%M:%S", tonumber(info.addtime) ) or "")
    itemnode:getChildByName("price_num"):setString(info.total_price)
    local status
    if info.status == "1" then
        status = "充值中"
    elseif info.status == "2" then
        status = "充值成功"
    elseif info.status == "3" then
        status = "充值失败"
    end
    itemnode:getChildByName("status"):setString(status)
end

function clsAgentDealDetail:ClearPage(Type)
    if Type == 0 then
        self.ListView_1:removeAllChildren()
    elseif Type == 1 then
        self.ListView_2:removeAllChildren()
    elseif Type == 2 then
        self.ListView_3:removeAllChildren()
    end
end