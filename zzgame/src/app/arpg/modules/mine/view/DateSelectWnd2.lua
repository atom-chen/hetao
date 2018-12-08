-------------------------
-- 日期选择
-------------------------
module("ui", package.seeall)

clsDateSelectWnd2 = class("clsDateSelectWnd2", clsBaseUI)

function clsDateSelectWnd2:ctor(parent, callback)
	clsBaseUI.ctor(self, parent, "uistu/DateSelect2.csb", true)
	
	self.ListYear:setItemModel(self.ListItem)
	self.ListMonth:setItemModel(self.ListItem)
	self.ListDay:setItemModel(self.ListItem)
	self.ListYear:setScrollBarEnabled(false)
	self.ListMonth:setScrollBarEnabled(false)
	self.ListDay:setScrollBarEnabled(false)
	
	self._sureCallback = callback
    
    self:InitUI()
    
	utils.RegClickEvent(self.BtnCancel,function() 
        self:removeSelf()
    end)
    
    utils.RegClickEvent(self.BtnSure,function() 
        if self._sureCallback then 
			local tTime = {
				year = self._selectYear,
				month = self._selectMonth,
				day = self._selectDay,
			}
			if not tTime.year then utils.TellMe("请填入正确的年份") return end
			if not tTime.month then utils.TellMe("请填入正确的月份") return end
			if not tTime.day then utils.TellMe("请填入正确的日期") return end
        	self._sureCallback(tTime) 
        	self:removeSelf()
        end
    end)
end

function clsDateSelectWnd2:dtor()
	
end

function clsDateSelectWnd2:OnSelectYear(item)
	self._selectYear = item._fix_index
	local items = self.ListYear:getItems()
	for _, wnd in ipairs(items) do
		if wnd == item then
			wnd:setTitleColor(cc.c3b(255,0,0))
		else
			wnd:setTitleColor(cc.c3b(0,0,0))
		end
	end
	self:InitListDay(1, libtime.Days(self._selectYear or 1990, self._selectMonth or 1))
	self.lblTime:setString(string.format("%d-%02d-%02d", self._selectYear or 1990, self._selectMonth or 1, self._selectDay or 1))
end
function clsDateSelectWnd2:OnSelectMonth(item)
	self._selectMonth = item._fix_index
	local items = self.ListMonth:getItems()
	for _, wnd in ipairs(items) do
		if wnd == item then
			wnd:setTitleColor(cc.c3b(255,0,0))
		else
			wnd:setTitleColor(cc.c3b(0,0,0))
		end
	end
	self:InitListDay(1, libtime.Days(self._selectYear or 1990, self._selectMonth or 1))
	self.lblTime:setString(string.format("%d-%02d-%02d", self._selectYear or 1990, self._selectMonth or 1, self._selectDay or 1))
end
function clsDateSelectWnd2:OnSelectDay(item)
	self._selectDay = item._fix_index
	local items = self.ListDay:getItems()
	for _, wnd in ipairs(items) do
		if wnd == item then
			wnd:setTitleColor(cc.c3b(255,0,0))
		else
			wnd:setTitleColor(cc.c3b(0,0,0))
		end
	end
	self.lblTime:setString(string.format("%d-%02d-%02d", self._selectYear or 1990, self._selectMonth or 1, self._selectDay or 1))
end

function clsDateSelectWnd2:InitListYear(fromYear, toYear)
	local idx = 2
	local listWnd = self.ListYear
	listWnd:removeAllItems()
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(0):setTitleText("")
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(1):setTitleText("")
	for d = fromYear, toYear do
		listWnd:pushBackDefaultItem()
		local item = listWnd:getItem(idx)
		item:setTitleText(d)
		item._fix_index = d
		utils.RegClickEvent(item, function()
			self.ListYear:jumpToItem(self.ListYear:getIndex(item),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectYear(item)
		end)
		idx = idx + 1
	end 
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	
	listWnd:addScrollViewEventListener(function(sender, evenType)
		if evenType ~= 10 then return end
		if true then
			listWnd:stopAutoScroll()
			local toppestItem = listWnd:getBottommostItemInCurrentView()
			local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
			local index = toppestIdx
			self:DestroyTimer("tmscrollyear")
			self:CreateTimerDelay("tmscrollyear", 5, function()
				listWnd:jumpToItem(index,cc.p(0,0),cc.p(0,0))
				self:OnSelectYear(listWnd:getItem(index-2))
			end)
		end
	end)
end
function clsDateSelectWnd2:InitListMonth(fromMonth, toMonth)
	local idx = 2
	local listWnd = self.ListMonth
	listWnd:removeAllItems()
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(0):setTitleText("")
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(1):setTitleText("")
	for d = fromMonth, toMonth do
		listWnd:pushBackDefaultItem()
		local item = listWnd:getItem(idx)
		item:setTitleText(d)
		item._fix_index = d
		utils.RegClickEvent(item, function()
			self.ListMonth:jumpToItem(self.ListMonth:getIndex(item),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectMonth(item)
		end)
		idx = idx + 1
	end 
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	
	listWnd:addScrollViewEventListener(function(sender, evenType)
		if evenType ~= 10 then return end
		if true then
			listWnd:stopAutoScroll()
			local toppestItem = listWnd:getBottommostItemInCurrentView()
			local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
			local index = toppestIdx
			self:DestroyTimer("tmscrollmonth")
			self:CreateTimerDelay("tmscrollmonth", 5, function()
				listWnd:jumpToItem(index,cc.p(0,0),cc.p(0,0))
				self:OnSelectMonth(listWnd:getItem(index-2))
			end)
		end
	end)
end
function clsDateSelectWnd2:InitListDay(fromDay, toDay)
	if self._fromDay and self._toDay then
		if self._fromDay == fromDay and self._toDay == toDay then return end
	end
	self._fromDay = fromDay
	self._toDay = toDay
	
	local oldSelect = self._selectDay
	
	local idx = 2
	local listWnd = self.ListDay
	listWnd:removeAllItems()
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(0):setTitleText("")
	listWnd:pushBackDefaultItem()
	local item = listWnd:getItem(1):setTitleText("")
	for d = fromDay, toDay do
		listWnd:pushBackDefaultItem()
		local item = listWnd:getItem(idx)
		item:setTitleText(d)
		item._fix_index = d
		utils.RegClickEvent(item, function()
			self.ListDay:jumpToItem(self.ListDay:getIndex(item),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectDay(item)
		end)
		idx = idx + 1
	end 
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	local item = self.ListItem:clone()
	item:setTitleText("")
	listWnd:pushBackCustomItem(item)
	
	listWnd:addScrollViewEventListener(function(sender, evenType)
		if evenType ~= 10 then return end
		if true then
			listWnd:stopAutoScroll()
			local toppestItem = listWnd:getBottommostItemInCurrentView()
			local toppestIdx = toppestItem and listWnd:getIndex(toppestItem)
			local index = toppestIdx
			self:DestroyTimer("tmscrollday")
			self:CreateTimerDelay("tmscrollday", 5, function()
				listWnd:jumpToItem(index,cc.p(0,0),cc.p(0,0))
				self:OnSelectDay(listWnd:getItem(index-2))
			end)
		end
	end)
	
	if oldSelect and oldSelect <= toDay then
		self:SetSelectedDay(oldSelect)
	end
end

function clsDateSelectWnd2:SetSelectedYear(year)
	self.ListYear:stopAutoScroll()
	local items = self.ListYear:getItems()
	for _, wnd in ipairs(items) do
		if wnd._fix_index == year then
			self.ListYear:jumpToItem(self.ListYear:getIndex(wnd),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectYear(wnd)
			break
		end
	end
end
function clsDateSelectWnd2:SetSelectedMonth(month)
	self.ListMonth:stopAutoScroll()
	local items = self.ListMonth:getItems()
	for _, wnd in ipairs(items) do
		if wnd._fix_index == month then
			self.ListMonth:jumpToItem(self.ListMonth:getIndex(wnd),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectMonth(wnd)
			break
		end
	end
end
function clsDateSelectWnd2:SetSelectedDay(day)
	self.ListDay:stopAutoScroll()
	local items = self.ListDay:getItems()
	for _, wnd in ipairs(items) do
		if wnd._fix_index == day then
			self.ListDay:jumpToItem(self.ListDay:getIndex(wnd),cc.p(0.5,0.5),cc.p(0.5,0.5))
			self:OnSelectDay(wnd)
			break
		end
	end
end

function clsDateSelectWnd2:InitUI()
	self:InitListYear(1950, 2018)
	self:InitListMonth(1,12)
	self:InitListDay(1, 30)
	
	self:SetSelectedYear(1990)
	self:SetSelectedMonth(1)
	self:SetSelectedDay(22)
end
