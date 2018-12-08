-------------------------
--投注记录
-------------------------
module("ui",package.seeall)

local PAGE_SIZE = 15
local cacheData = {}
local waitingPages = {}

local function ReqData(Type, Page)
	if Page == 1 then
		cacheData[Type] = {}	
	end
	
	if cacheData[Type] and cacheData[Type].pageList and cacheData[Type].pageList[Page] then
		print("取缓存数据", Type, Page)
		return cacheData[Type].pageList[Page]
	end
	local waitKey = Type..Page 
	if waitingPages[waitKey] then
		print("等待数据返回中", Type, Page)
		KE_SetTimeout(60, function() waitingPages[waitKey] = nil end)
		return nil
	end
	waitingPages[waitKey] = true
	
	local params = {}
	params.type = Type
	params.page = Page
	proto.req_user_bet_record_get_list(params, nil, function(recvdata)
		waitingPages[waitKey] = nil 
		local data = recvdata and recvdata.data
		if data then
			cacheData[Type] = cacheData[Type] or {}
			cacheData[Type].total = tonumber(data.total)
			cacheData[Type].pageList = cacheData[Type].pageList or {}
			cacheData[Type].pageList[Page] = data.rows
		else
			if PlatformHelper.isNetworkConnected() then
				cacheData[Type] = cacheData[Type] or {}
				cacheData[Type]._forceAllLoad = true
			end
		end
	end)
end

clsBetHistoryView = class("clsBatHistoryView",clsBaseUI)

function clsBetHistoryView:ctor(parent)
	clsBaseUI.ctor(self,parent,"uistu/BetHistory.csb")
	self.ListView1:setScrollBarEnabled(false)
    self.ListView2:setScrollBarEnabled(false)
    self.ListView3:setScrollBarEnabled(false)
    self.ListView4:setScrollBarEnabled(false)
    self.ListView1:setSwallowTouches(false)
    self.ListView2:setSwallowTouches(false)
    self.ListView3:setSwallowTouches(false)
    self.ListView4:setSwallowTouches(false)
    
    waitingPages = {}
    cacheData = {}
    
    self.lblTipRefresh:setVisible(false)
    self:InUiEvent()
    
    g_EventMgr:AddListener(self,"on_req_user_bet_record_get_list",self.RefleshPage,self)
    g_EventMgr:AddListener(self,"error_req_user_bet_record_get_list",self.RefleshPage,self)
    
    self:SwitchTo(0)
    
    local tcLayer = cc.Node:create()
	self:addChild(tcLayer)
	local function onTouchBegan(touch, event)
	--	logger.normal("==== begin", touch:getLocation().x, touch:getLocation().y)
		self._beginX = touch:getLocation().x
		self._beginY = touch:getLocation().y
		return true
	end
	local function onTouchMoved(touch, event)
	--	logger.normal("==== move", touch:getDelta().x, touch:getDelta().y)
		
	end
	local function onTouchEnded(touch, event)
	--	logger.normal("==== end", touch:getLocation().x, touch:getLocation().y)
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

function clsBetHistoryView:dtor()

end

function clsBetHistoryView:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local w = self.PanelPages:getContentSize().width
	local h = self:GetAdaptInfo().hAuto-90-10
	self.PanelPages:setContentSize(w, h)
	self.Panel_1:setContentSize(w, h)
	self.Panel_2:setContentSize(w, h)
	self.Panel_3:setContentSize(w, h)
	self.Panel_4:setContentSize(w, h)
	self.ListView1:setContentSize(w, h)
	self.ListView2:setContentSize(w, h)
	self.ListView3:setContentSize(w, h)
	self.ListView4:setContentSize(w, h)
end

function clsBetHistoryView:SwitchTo(nPage)
	if nPage < 0 then nPage = 0 end
	if nPage > 3 then nPage = 3 end
	self._curPage = nPage
	self:OnTurn2Page(nPage)
end

function clsBetHistoryView:OnTurn2Page(nPage)
	print( "------- 页:", nPage )
	local highColor = cc.c3b(255,0,0)
    local normalColor = cc.c3b(0,0,0)
    self.Text_5:setTextColor( nPage==0 and highColor or normalColor )
    self.Text_6:setTextColor( nPage==1 and highColor or normalColor)
    self.Text_7:setTextColor( nPage==3 and highColor or normalColor)
    self.Text_8:setTextColor( nPage==2 and highColor or normalColor)
    for i=1,4 do
		self["ListView"..i]:stopAutoScroll()
		self["ListView"..i]:forceDoLayout()
	end
    local dstX = -self.PanelPages:getContentSize().width * nPage
    self.PanelPages:stopAllActions()
    local useTime = math.abs(self.PanelPages:getPositionX()-dstX) / 2000
    self.PanelPages:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.PanelPages:getPositionY())))
    
    self:RefleshPage()
    
	ReqData(self:GetTypeByPageIdx(nPage), 1)
end

function clsBetHistoryView:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
    g_EventMgr:AddListener(self,"cancelbet",function(this,data)
        cacheData = {}
        waitingPages = {}
        local listWnd 
        local ntype = tonumber(data.type) - 1
        if ntype == 0 then
		    listWnd = self.ListView1
	    elseif ntype == 1 then
		    listWnd = self.ListView2
	    elseif ntype == 2 then
		    listWnd = self.ListView3
	    elseif ntype == 3 then
		    listWnd = self.ListView4
	    end
        listWnd:removeAllChildren()
        ReqData(tostring(ntype),data.page)
    end,self)
    utils.RegClickEvent(self.BtnTouzhu1, function() self:removeSelf() ClsUIManager.GetInstance():ShowView("clsHallUI"):SwitchTo(2) end)
    utils.RegClickEvent(self.BtnTouzhu2, function() self:removeSelf() ClsUIManager.GetInstance():ShowView("clsHallUI"):SwitchTo(2) end)
    utils.RegClickEvent(self.BtnTouzhu3, function() self:removeSelf() ClsUIManager.GetInstance():ShowView("clsHallUI"):SwitchTo(2) end)
    utils.RegClickEvent(self.BtnTouzhu4, function() self:removeSelf() ClsUIManager.GetInstance():ShowView("clsHallUI"):SwitchTo(2) end)
    
    utils.RegClickEvent(self.Btn_all,function() 
        self:SwitchTo(0)
    end)
    utils.RegClickEvent(self.Btn_bingo,function()
        self:SwitchTo(1)
    end)
    utils.RegClickEvent(self.Btn_wait,function()
        self:SwitchTo(3)
    end)
    utils.RegClickEvent(self.Btn_undo,function()
        self:SwitchTo(2)
    end)
    
    self.ListView1:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView1:getInnerContainerPosition().y > 0 then
        	local items = self.ListView1:getItems()
        	local cnt = #items
        	if cnt > 0 then
	        	local wantPage = math.ceil((cnt+1)/PAGE_SIZE)
	        	local wantType = self:GetTypeByPageIdx(0)
	        	if cacheData[wantType] and cacheData[wantType].total and cnt >= cacheData[wantType].total then
	        		logger.normal("已经获取了所有的数据", 0, wantType, wantPage)
	        	else
		        	if cacheData[wantType] and cacheData[wantType].pageList and cacheData[wantType].pageList[wantPage] then
		        		logger.normal("已经缓存了该页数据：", 0, wantType, wantPage)
		        	else
		        		logger.normal("请求该页数据：", 0, wantType, wantPage)
		        		ReqData(wantType, wantPage)
		        	end
		        end
		    end
		elseif eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView4:getInnerContainerPosition().y < 0 then
			local wantPage = 1
			local wantType = self:GetTypeByPageIdx(0)
			ReqData(wantType, wantPage)
    	end
    end )
    self.ListView2:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView2:getInnerContainerPosition().y > 0 then
        	local items = self.ListView2:getItems()
        	local cnt = #items
        	if cnt > 0 then
	        	local wantPage = math.ceil((cnt+1)/PAGE_SIZE)
	        	local wantType = self:GetTypeByPageIdx(1)
	        	if cacheData[wantType] and cacheData[wantType].total and cnt >= cacheData[wantType].total then
	        		logger.normal("已经获取了所有的数据", 1, wantType, wantPage)
	        	else
		        	if cacheData[wantType] and cacheData[wantType].pageList and cacheData[wantType].pageList[wantPage] then
		        		logger.normal("已经缓存了该页数据：", 1, wantType, wantPage)
		        	else
		        		logger.normal("请求该页数据：", 1, wantType, wantPage)
		        		ReqData(wantType, wantPage)
		        	end
		        end
		    end
		elseif eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView4:getInnerContainerPosition().y < 0 then
			local wantPage = 1
			local wantType = self:GetTypeByPageIdx(1)
			ReqData(wantType, wantPage)
    	end
    end )
    self.ListView3:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView3:getInnerContainerPosition().y > 0 then
        	local items = self.ListView3:getItems()
        	local cnt = #items
        	if cnt > 0 then
	        	local wantPage = math.ceil((cnt+1)/PAGE_SIZE)
	        	local wantType = self:GetTypeByPageIdx(2)
	        	if cacheData[wantType] and cacheData[wantType].total and cnt >= cacheData[wantType].total then
	        		logger.normal("已经获取了所有的数据", 2, wantType, wantPage)
	        	else
		        	if cacheData[wantType] and cacheData[wantType].pageList and cacheData[wantType].pageList[wantPage] then
		        		logger.normal("已经缓存了该页数据：", 2, wantType, wantPage)
		        	else
		        		logger.normal("请求该页数据：", 2, wantType, wantPage)
		        		ReqData(wantType, wantPage)
		        	end
		        end
		    end
		elseif eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView3:getInnerContainerPosition().y < 0 then
			local wantPage = 1
			local wantType = self:GetTypeByPageIdx(2)
			ReqData(wantType, wantPage)
    	end
    end )
    self.ListView4:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView4:getInnerContainerPosition().y > 0 then
        	local items = self.ListView4:getItems()
        	local cnt = #items
        	if cnt > 0 then
	        	local wantPage = math.ceil((cnt+1)/PAGE_SIZE)
	        	local wantType = self:GetTypeByPageIdx(3)
	        	if cacheData[wantType] and cacheData[wantType].total and cnt >= cacheData[wantType].total then
	        		logger.normal("已经获取了所有的数据", 3, wantType, wantPage)
	        	else
		        	if cacheData[wantType] and cacheData[wantType].pageList and cacheData[wantType].pageList[wantPage] then
		        		logger.normal("已经缓存了该页数据：", 3, wantType, wantPage)
		        	else
		        		logger.normal("请求该页数据：", 3, wantType, wantPage)
		        		ReqData(wantType, wantPage)
		        	end
		        end
		    end
		elseif eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListView4:getInnerContainerPosition().y < 0 then
			local wantPage = 1
			local wantType = self:GetTypeByPageIdx(3)
			ReqData(wantType, wantPage)
    	end
    end )
end

function clsBetHistoryView:GetTypeByPageIdx(nPage)
	if nPage == 0 then  	--全部
		return "0"
	elseif nPage == 1 then	--已中奖
		return "1"
	elseif nPage == 3 then	--待开奖
		return "4"
	elseif nPage == 2 then	--已撤单
		return "3"
	end
end

function clsBetHistoryView:RefleshPage()
    local nPage = self._curPage
	local Type = self:GetTypeByPageIdx(nPage)
	if not Type then return end
	
	logger.normal("刷新页面：", nPage, Type)
	
	local listWnd 
	local sprEmptyTip
    if nPage == 0 then
		listWnd = self.ListView1
		sprEmptyTip = self.no_1
	elseif nPage == 1 then
		listWnd = self.ListView2
		sprEmptyTip = self.no_2
	elseif nPage == 2 then
		listWnd = self.ListView4
		sprEmptyTip = self.no_4
	elseif nPage == 3 then
		listWnd = self.ListView3
		sprEmptyTip = self.no_3
	end
	
	local pageList = cacheData and cacheData[Type] and cacheData[Type].pageList
	if not pageList then return end
	
	gameutil.UnMarkAllLoaded(listWnd)
	
	listWnd:stopAutoScroll()
	local toppestItem = listWnd:getBottommostItemInCurrentView()
	local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
	
	local bEmptyFlag = true
	local curIndex = 0
	for i=1, 100 do
		if pageList[i] then
			for _, info in ipairs(pageList[i]) do
				local item = listWnd:getItem(curIndex)
				bEmptyFlag = false
				if item then
					self:RefleshItem(item, info, i)
					curIndex = curIndex + 1 
				else 
					item = self.ItemPanel:clone()
					listWnd:pushBackCustomItem(item)
					utils.getNamedNodes(item)
					self:RefleshItem(item, info, i)
					curIndex = listWnd:getIndex(item) + 1
					item:setSwallowTouches(false)
				end
			end
		else
			break
		end
	end
	
	local count = #listWnd:getItems()
	for i=count, curIndex, -1 do
		listWnd:removeItem(i)
	end
	
	local total = cacheData[Type].total
	if total and curIndex+1 >= total or cacheData[Type]._forceAllLoad then
		gameutil.MarkAllLoaded(listWnd)
	end
	
	if toppestIdx and toppestIdx >= 0 and pageList[2] then
		listWnd:stopAutoScroll()
		listWnd:forceDoLayout()
		listWnd:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	end 
	
	sprEmptyTip:setVisible(bEmptyFlag)
end

function clsBetHistoryView:RefleshItem(item, info, page)
    item.date:setString(info.issue.."期")
    item.game_name:setString(info.game)
    item.game_way:setString(info.tname)
    item.game_money:setString("投注"..info.price_sum.."元")
    
    if info.status == "1" then
        item.mark:setVisible(true)
        item.game_state:setString("中奖"..info.win_price.."元")
        item.game_money:setPosition(item.game_money:getPositionX(),48)
        item.game_state:setTextColor(cc.c3b(255,0,0))
    elseif info.status == "2" then
        item.game_state:setString("和局")
    elseif info.status == "3" then
        item.game_state:setString("已撤单")
    elseif info.status == "4" then
        item.game_state:setString("待开奖")
    elseif info.status == "5" then
        item.game_state:setString("未中奖")
    end
    item.game_money:setTextColor(cc.c3b(255,0,0))
    utils.RegClickEvent(item,function() 
    	if math.abs(self._deltaX) < 8 then
	        ClsBetHistoryMgr.GetInstance():SaveBetDetails(info)
	        ClsBetHistoryMgr.GetInstance():SavePage(page)
	        ClsUIManager.GetInstance():ShowPanel("clsBetDetailsView")
	    end
    end)
end
