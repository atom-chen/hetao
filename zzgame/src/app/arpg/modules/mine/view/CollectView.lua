-------------------------
-- 我的收藏
-------------------------
module("ui", package.seeall)

clsCollectView = class("clsCollectView", clsBaseUI)

function clsCollectView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/CollectView.csb")
	self.ListView_1 = self.AreaAuto
	self.ListView_1:setItemModel(self.ListItem)
	KE_SafeDelete(self.ListItem)
	self.ListItem = nil
	
    g_EventMgr:AddListener(self,"on_req_user_get_favorite",self.RefleshUI,self)
    g_EventMgr:AddListener(self,"on_req_user_set_favorite",function()
        proto.req_user_get_favorite()
    end)

	self:ChangeDelState(false)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	proto.req_user_get_favorite()
end

function clsCollectView:dtor()
	
end

function clsCollectView:ChangeDelState(bStateDel)
	self._bStateDel = bStateDel
	local allitems = self.ListView_1:getItems() or {}
	if bStateDel then
		self.BtnDel:setTitleText("取消")
		for _, item in ipairs(allitems) do
			item:getChildByName("CheckBox_1"):setVisible(true)
            item:setTouchEnabled(false)
		end
		self.BtnSelectAll:setVisible(true)
		self.BtnSure:setVisible(true)
	else
		self.BtnDel:setTitleText("删除")
		for _, item in ipairs(allitems) do
			item:getChildByName("CheckBox_1"):setSelected(false)
			item:getChildByName("CheckBox_1"):setVisible(false)
            item:setTouchEnabled(true)
		end
		self.BtnSelectAll:setTitleText("全选")
		self.BtnSelectAll:setVisible(false)
		self.BtnSure:setVisible(false)
	end
	
	if self._bStateDel then
		self.AreaAuto:setContentSize(self.AreaAuto:getContentSize().width, self.RootView:getContentSize().height-self.AreaTop:getContentSize().height-self.AreaBottom:getContentSize().height)
		self.AreaAuto:setPositionY(self.AreaAuto:getContentSize().height+self.AreaBottom:getContentSize().height)
	else
		self.AreaAuto:setContentSize(self.AreaAuto:getContentSize().width, self.RootView:getContentSize().height-self.AreaTop:getContentSize().height)
		self.AreaAuto:setPositionY(self.AreaAuto:getContentSize().height)
	end
end

--注册控件事件
function clsCollectView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnDel, function() 
		self:ChangeDelState(not self._bStateDel)
	end)
	utils.RegClickEvent(self.BtnSelectAll, function() 
		local allitems = self.ListView_1:getItems() or {}
		local bAllSel = true
		for _, item in ipairs(allitems) do
			if not item:getChildByName("CheckBox_1"):isSelected() then
				bAllSel = false
				break
			end
		end
		
		if bAllSel then
			self.BtnSelectAll:setTitleText("全选")
		else 
			self.BtnSelectAll:setTitleText("取消")
		end
		
		for _, item in ipairs(allitems) do
			item:getChildByName("CheckBox_1"):setSelected(not bAllSel)
		end
	end)
	utils.RegClickEvent(self.BtnSure, function() 
        local dellist = {}
		local allitems = self.ListView_1:getItems() or {}
		local cnt = #allitems
		for i=cnt, 1, -1 do
            item = self.ListView_1:getItem(i-1)
			if item:getChildByName("CheckBox_1"):isSelected() then
                table.insert(dellist, item._info.id)
			end
		end
		if #dellist <= 0 then
			return
		end
        local gids = table.concat(dellist, ",")
        proto.req_user_set_favorite({gid = gids,status = "1"})
	end)
end

-- 注册全局事件
function clsCollectView:InitGlbEvents()
	
end

function clsCollectView:RefleshUI(recvdata)
	self.ListView_1:removeAllItems()
	local data = recvdata and recvdata.data or {}
	
	self.no_1:setVisible(#data == 0)
	self.BtnDel:setVisible(#data > 0)
    
    if not data then return end 
    
	for idx, info in ipairs(data) do
		self.ListView_1:pushBackDefaultItem()
		local item = self.ListView_1:getItem(idx-1)
		item:getChildByName("ImgGameIcon"):LoadTextureSync(info.img)
		item:getChildByName("lblGameName"):setString(info.name)
		item._info = info
		
		local gid, cptype, name = tonumber(info.id), info.type, info.name
        utils.RegClickEvent(item,function()
        	if self._bStateDel then return end
        	if self._bLeaving then return end
        	self._bLeaving = true
        	self:CreateTimerDelay("tmr_leave", 1, function()
        		self:removeSelf()
            	ClsGameMgr.GetInstance():OpenGame(gid, cptype, name)
        	end)
        end)
	end
    
    self:ChangeDelState(false)
end
