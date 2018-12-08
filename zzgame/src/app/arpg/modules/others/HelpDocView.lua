-------------------------
-- 玩法规则
-------------------------
module("ui", package.seeall)

clsHelpDocView = class("clsHelpDocView", clsBaseUI)

function clsHelpDocView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/HelpDocView.csb")
	
	if device.platform ~= "windows" then
    	local webView = ccexp.WebView:create()
    	self:addChild(webView)
    	webView:setContentSize(720,self:GetAdaptInfo().hAuto-self.ListGames:getContentSize().height)
    	webView:setAnchorPoint(cc.p(0,0))
    	self.webView = webView
    	webView:setBounces(false)
    	webView:setScalesPageToFit(true)
    else
    	self.htmlText = ScrollHtmlText.new( {
			width = 700,
			height = self:GetAdaptInfo().hAuto-self.ListGames:getContentSize().height,
			color = cc.c3b(0,0,0),
			size = 24,
			fixWidth = 700,
		})
		self.htmlText:setVerticalSpace(8)
		self.htmlText:setPosition(10,0)
		self:addChild(self.htmlText)
    end
	
	self.ListGames:setPositionY(self:GetAdaptInfo().hAuto)
	self.ListGames:setScrollBarEnabled(false)
	self.ListGames:setItemModel(self.ListItemGames)
	KE_SafeDelete(self.ListItemGames)
	self.ListItemGames = nil
	
	self:InitTabArea()
	
	self:InitUiEvents()
	self:InitGlbEvents()
end

function clsHelpDocView:dtor()
	
end

function clsHelpDocView:InitTabArea()
	local listWnd = self.ListGames
	local idx = 0
	self._idx2key = {}
	for key, info in pairs(const.GAME_TYPE) do
		listWnd:pushBackDefaultItem()
		local item = listWnd:getItem(idx)
		item:getChildByName("lblGameName"):setString(info.client_gamename)
		
		self._idx2key[idx] = key
		idx = idx + 1
	end
	listWnd:addEventListener(function(sender, eventType)
		if ccui.ListViewEventType.ONSELECTEDITEM_END == eventType then
			local curIndex = listWnd:getCurSelectedIndex()
			
			-- 高亮显示选中元素
			local allItems = listWnd:getItems()
			for i, wnd in pairs(allItems) do
				if i-1 == curIndex then
					wnd:getChildByName("lblGameName"):setTextColor(cc.c3b(225,22,22))
                    wnd:getChildByName("underline"):setVisible(true)
				else
					wnd:getChildByName("lblGameName"):setTextColor(cc.c3b(22,22,22))
                    wnd:getChildByName("underline"):setVisible(false)
				end
			end
			
			--刷新页面
			local Type = self._idx2key[curIndex]
			if Type == "kl10" then Type="s_kl10" end
			local cachedData = ClsHelpDocMgr.GetInstance():GetContent(Type)
			if cachedData then
				self:on_req_helpdoc_play_rule(cachedData, {type=Type})
			else
				proto.req_helpdoc_play_rule({type=Type})
			end
		end 
	end)
end

function clsHelpDocView:ShowPage(key)
	local curIndex = 0
	for idx, gname in pairs(self._idx2key) do
		if key == gname then
			curIndex = idx
			break
		end
	end
	print("ssssssssssss", curIndex, key)
	self.ListGames:setCurSelectedIndex(curIndex)
	self.ListGames:scrollToItem(curIndex, cc.p(0.5,0.5), cc.p(0.5,0.5))
	self:DestroyTimer("tmsss")
	self:CreateTimerDelay("tmsss", 1, function()
		self.ListGames:scrollToItem(curIndex, cc.p(0.5,0.5), cc.p(0.5,0.5))
	end)
end

function clsHelpDocView:SetPageIdx(idx)
	if idx<1 then idx = 1 end
	if idx>table.size(const.GAME_TYPE) then idx = table.size(const.GAME_TYPE) end
	self.ListGames:setCurSelectedIndex(idx-1)
end

--注册控件事件
function clsHelpDocView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
end

-- 注册全局事件
function clsHelpDocView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_helpdoc_play_rule", self.on_req_helpdoc_play_rule, self)
end

function clsHelpDocView:on_req_helpdoc_play_rule(recvdata, tArgs)
	local cachedData = ClsHelpDocMgr.GetInstance():GetContent(tArgs.type) or recvdata
	if self.webView then
		self.webView:loadHTMLString(cachedData or "")
		self.webView:setScalesPageToFit(true)
	end
	if self.htmlText then self.htmlText:setString(cachedData or "") end
end
