-------------------------
-- 账户明细
-------------------------
module("ui", package.seeall)

local PAGE_SIZE = 15
local cacheData = {}
local waitingPages = {}

local function GetKey(wantPage, conditions)
	local key = conditions.typeinfo.type.."_"..wantPage.."_"..conditions.time_start.."_"..conditions.time_end
	return key
end

local function ReqData(wantPage, conditions)
	local key = GetKey(wantPage, conditions)
    if cacheData[key] then
    	print("已缓存", wantPage, key)
        return cacheData[key]
    end
    if waitingPages[key] then
		print("等待数据返回中", key)
		KE_SetTimeout(60, function() waitingPages[key] = nil end)
		return nil
	end
	waitingPages[key] = true
    local params = {}
    params.type = conditions.typeinfo.type or ""
    params.time_start = conditions.time_start or ""
	params.time_end = conditions.time_end or ""
    params.page = wantPage
    print("发起服务器请求", wantPage, key)
    proto.req_user_zhanghu_mingxi(params, nil, function(recvdata)
		waitingPages[key] = nil 
		local _data = recvdata and recvdata.data and recvdata.data.rows
		if _data then
			cacheData[key] = {
				rows = _data,
				total = tonumber(recvdata.data.total),
			}
		end
	end)
end

clsAccountDetail = class("clsAccountDetail", clsBaseUI)

function clsAccountDetail:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AccountDetail.csb")
	self.ListViewDetail = self.AreaAuto
	self.ListViewDetail:setScrollBarEnabled(false)
	
	cacheData = {}
	waitingPages = {}
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	self._conditions = {
    	time_start = "",
    	time_end = "",
    	typeinfo = { type = "", name="全部" },
    }
    ReqData(1, self._conditions)
end

function clsAccountDetail:dtor()
	
end

--注册控件事件
function clsAccountDetail:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_2, function()
        local argInfo = {
       		ScreetType = "ACCOUNT_DETAIL",
       		callback = function(conditions)
       			print("筛选")
       			self._conditions = conditions
		        cacheData = {}
		        waitingPages = {}
		        logger.dump(conditions)
		        self.ListViewDetail:removeAllItems()
		        ReqData(1, self._conditions)
       		end,
       	}
        ClsUIManager.GetInstance():ShowPopWnd("clsScreeningWnd", argInfo)
    end)
    self.ListViewDetail:addScrollViewEventListener( function(sender, eventType)
        if eventType == ccui.ScrollviewEventType.autoscrollEnded and self.ListViewDetail:getInnerContainerPosition().y > 0 then
        	local items = self.ListViewDetail:getItems()
        	local cnt = #items
        	if cnt > 0 then
	        	local wantPage = math.ceil((cnt+1)/PAGE_SIZE)
	        	print("请求页", wantPage)
	        	ReqData(wantPage, self._conditions)
		    end
    	end
    end )
end

-- 注册全局事件
function clsAccountDetail:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_zhanghu_mingxi", self.on_req_user_zhanghu_mingxi, self)
end

function clsAccountDetail:CreateItem(info)
	local itemWnd = self.ListItem:clone()
	itemWnd:getChildByName("lblOrder"):setString("订单号："..info.order_num)
	itemWnd:getChildByName("lblName"):setString(info.name)
	itemWnd:getChildByName("lblTime"):setString(info.addtime)
	itemWnd:getChildByName("lblMoney"):setString(info.amount .. "元")
	gameutil.RegCopyEvent(itemWnd:getChildByName("lblOrder"), info.order_num)
	return itemWnd
end

function clsAccountDetail:on_req_user_zhanghu_mingxi(recvdata)
	local listWnd = self.ListViewDetail
    
    gameutil.UnMarkAllLoaded(listWnd)
    
	listWnd:stopAutoScroll()
	local toppestItem = listWnd:getBottommostItemInCurrentView()
	local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
	
	local preLen = #listWnd:getItems()
	local total 
	local curIndex = 0
	local bUnFull = false
	for iPage = 1, 100 do
		local key = GetKey(iPage, self._conditions)
		print("====", iPage, key, cacheData[key])
		if not cacheData[key] then break end
		total = cacheData[key].total
		local infolist = cacheData[key].rows
		for _, info in ipairs(infolist) do
			local itemWnd = listWnd:getItem(curIndex)
			if not itemWnd then
				itemWnd = self:CreateItem(info)
				listWnd:pushBackCustomItem(itemWnd)
			end
			curIndex = curIndex + 1
		end
		if #infolist < PAGE_SIZE then bUnFull = true end
	end
	for i = preLen, curIndex, -1 do
		listWnd:removeItem(i)
	end
	
	if total and #listWnd:getItems() >= total or bUnFull then
		gameutil.MarkAllLoaded(listWnd)
	end
		
	if toppestIdx and toppestIdx >= 0 then
		listWnd:stopAutoScroll()
		listWnd:forceDoLayout()
		listWnd:jumpToItem(toppestIdx,cc.p(0,0),cc.p(0,1))
	end 
	
	self.nodata:setVisible(#listWnd:getItems()<=0)
end
