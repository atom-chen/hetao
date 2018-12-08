-------------------------
-- 首页
-------------------------
module("ui", package.seeall)

clsGouCaiView = class("clsGouCaiView", clsBaseUI)

function clsGouCaiView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/GouCaiView.csb")
	self.ScrollView_1 = self.AreaAuto
	self.ListViewGameType:setScrollBarEnabled(false)
	self.ScrollView_1:setScrollBarEnabled(false)
	
	self._hithSpr = utils.CreateScale9Sprite(RES_CONFIG.common_black)
	self._hithSpr:setContentSize(160, self.ListViewGameType:getContentSize().height)
	self._hithSpr:setPosition(80, self.ListViewGameType:getContentSize().height/2)
	self._hithSpr:retain()
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	self:CreateTimerDelay("tmrinit", 1, function()
		if not ClsGameMgr.GetInstance():GetAllGameInfo() then
			proto.req_goucai_all_games({use="all"})
		end
	end)
end

function clsGouCaiView:dtor()
	self._hithSpr:release()
end

function clsGouCaiView:OnShow(bShow)
	if not bShow then return end
	if not self:HasTimer("refresh_allgames") and not ClsGameMgr.GetInstance():GetAllGameInfo() then
		self:CreateAbsTimerLoop("refresh_allgames", 2, function()
			if not self:isVisible() then return true end
			if not ClsGameMgr.GetInstance():GetAllGameInfo() then
				proto.req_goucai_all_games({use="all"})
			else
				return true
			end
		end)
	end
end

--注册控件事件
function clsGouCaiView:InitUiEvents()
	
end

-- 注册全局事件
function clsGouCaiView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_goucai_all_games", self.on_req_goucai_all_games, self, true)
end

function clsGouCaiView:on_req_goucai_all_games(recvdata)
	local data = recvdata and recvdata.data or ClsGameMgr.GetInstance():GetAllGameInfo()
	if not data then return end
	self:DestroyTimer("refresh_allgames")
	self._gamelist = data
	self:InitListViewGameType(data)
end

function clsGouCaiView:CreateGameTypeBtn(info)
	logger.dump(info)
	local wid, hei = 160, self.ListViewGameType:getContentSize().height
	
	local BtnGameType = ccui.Button:create()
	BtnGameType:setScale9Enabled(true)
	BtnGameType:setContentSize(wid, hei)
	
	local lblName = utils.CreateLabel(info.cnname, 24)
	BtnGameType:addChild(lblName,1)
	lblName:setPosition(wid/2, 42)
	lblName:setColor(cc.c3b(222,222,222))
	BtnGameType.lblName = lblName
	
	local imgGameIcon = ccui.ImageView:create()
	BtnGameType:addChild(imgGameIcon,1)
	imgGameIcon:setPosition(wid/2, 100)
	BtnGameType.imgGameIcon = imgGameIcon
	imgGameIcon:setScale9Enabled(false)
	imgGameIcon:setContentSize(64,64)
	imgGameIcon:ignoreContentAdaptWithSize(false)
	local iconPath = info.img
	local selectPath = info.img2
	if const.GAME_TYPE[info.cptype] then
		iconPath = string.format("uistu/icon/%s.png", const.GAME_TYPE[info.cptype].icon_name)
		selectPath = string.format("uistu/icon/%s_1.png", const.GAME_TYPE[info.cptype].icon_name)
	end
	imgGameIcon:LoadTextureSync(iconPath)
--	imgGameIcon:LoadTextureSync(info.img)
    imgGameIcon:setScale(0.9)
    
    BtnGameType.iconPath = iconPath
    BtnGameType.selectPath = selectPath
	BtnGameType._gameinfo = info
	
	return BtnGameType
end

function clsGouCaiView:InitListViewGameType(data)
	local listWnd = self.ListViewGameType
	listWnd:removeAllItems()
	
    --local btnTypeAll = self:CreateGameTypeBtn({cnname="全部", img="uistu/common/navigate1.png"})
	local btnTypeAll = self:CreateGameTypeBtn({cnname="全部", img="uistu/icon/icon_more.png", img2 ="uistu/icon/icon_more_1.png"})
	listWnd:pushBackCustomItem(btnTypeAll)
	local alltypes = {}
	
	local allgameByType = {}
	for cnname, infos in pairs(data[1]) do
		local info = {}
		info.cnname = cnname
		for gid, gameinfo in pairs(infos) do
			info.img = gameinfo.img
			info.cptype = gameinfo.type
			break
		end
		info.gamesbygid = infos
		allgameByType[info.cptype] = info
	end
	
	local tablist = {}
	for _, clientinfo in pairs(const.GAME_TYPE) do table.insert(tablist, clientinfo) end
	table.sort(tablist, function(a,b) return a.sortidx<b.sortidx end)
	for _, tab in ipairs(tablist) do
		if allgameByType[tab.typeid] then
			local BtnGameType = self:CreateGameTypeBtn(allgameByType[tab.typeid])
			listWnd:pushBackCustomItem(BtnGameType)
			for _, game in pairs(allgameByType[tab.typeid].gamesbygid) do
				table.insert(alltypes, game)
			end
		end
	end
	
	listWnd:addEventListener(function(sender, eventType)
		if ccui.ListViewEventType.ONSELECTEDITEM_END == eventType then
			local curIndex = listWnd:getCurSelectedIndex()
			local selectedItem = curIndex and listWnd:getItem(curIndex)
			--
			local allItems = listWnd:getItems()
			for _, item in ipairs(allItems or {}) do
				if item == selectedItem then
					KE_SetParent(self._hithSpr, item)
					item.imgGameIcon:LoadTextureSync(item.selectPath)
					item.lblName:setColor(cc.c3b(255,255,255))
				else
					item.imgGameIcon:LoadTextureSync(item.iconPath)
					item.lblName:setColor(cc.c3b(222,222,222))
				end
			end
			--
			if curIndex == 0 then
				self:RefleshContent(alltypes)
			else
				if selectedItem._gameinfo then 
					self:RefleshContent(self._gamelist[1][selectedItem._gameinfo.cnname])
				end
			end
			
			listWnd:scrollToItem(curIndex, cc.p(0.5,0.5), cc.p(0.5,0.5))
		end 
	end)
	
	listWnd:setCurSelectedIndex(0)
end

function clsGouCaiView:RefleshContent(infotbl)
	if not infotbl then return end
	local infolist = {}
	for _, v in pairs(infotbl) do table.insert(infolist, v) end
	
	self.ScrollView_1:removeAllChildren()
	
	local cnt = #infolist
	local COL = 3
	local ROW = math.ceil(cnt/COL)
	local hei = 0  -- local hei = self.ListView_1:getContentSize().height
	local totalWid = 720
	local gridSize = totalWid / COL
	local btnSize = gridSize - 3
    local btnSizeHei = btnSize + 7
	local totalHei = math.max(hei + (gridSize+7) * ROW, self.ScrollView_1:getContentSize().height)
	self.ScrollView_1:setInnerContainerSize(cc.size(totalWid,totalHei))
	totalHei = self.ScrollView_1:getInnerContainerSize().height
--	self.ListView_1:setPosition(0,totalHei)
	local leftHei = totalHei - hei
	
	for idx=1, cnt do 
		local info = infolist[idx]
		local BtnGame = self:CreateGameBtn(btnSize,btnSizeHei,info.name,info.every_time,info.img)
		self.ScrollView_1:addChild(BtnGame)
		local r = math.ceil(idx/COL)
		local c = idx%COL
		if c == 0 then c=COL end
		BtnGame:setPosition( c*gridSize-gridSize/2, leftHei-(r*(gridSize+7)-gridSize/2) )
		
		utils.RegClickEvent(BtnGame, function()
			ClsGameMgr.GetInstance():OpenGame(tonumber(info.gid), info.type, info.name)
		end)
	end
end

function clsGouCaiView:CreateGameBtn(wid, hei, name, every_time, img)
	local BtnGame = utils.CreateButton("uistu/common/bg_white.png","uistu/common/light_gray.jpg")
	BtnGame:setScale9Enabled(true)
	BtnGame:setContentSize(wid,hei)
	
	local lblZhouqi = utils.CreateLabel(every_time, 22)
    lblZhouqi:setAdditionalKerning(3)
	BtnGame:addChild(lblZhouqi)
	lblZhouqi:setPosition(wid/2, 45)
	lblZhouqi:setColor(cc.c3b(99,99,99))
	BtnGame.lblZhouqi = lblZhouqi
	
	local lblName = utils.CreateLabel(name, 28)
    lblName:setAdditionalKerning(5)
	BtnGame:addChild(lblName)
	lblName:setPosition(wid/2, 85)
	lblName:setColor(cc.c3b(22,22,22))
	BtnGame.lblName = lblName
	
	local imgGameIcon = ccui.ImageView:create()
	BtnGame:addChild(imgGameIcon)
	imgGameIcon:setPosition(wid/2, hei*0.66)
	BtnGame.imgGameIcon = imgGameIcon
	imgGameIcon:setScale9Enabled(false)
	imgGameIcon:setContentSize(90,90)
	imgGameIcon:ignoreContentAdaptWithSize(false)
	imgGameIcon:LoadTextureSync(img)
	
	return BtnGame
end
