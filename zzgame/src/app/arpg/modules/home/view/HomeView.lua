-------------------------
-- 首页
-------------------------
module("ui", package.seeall)

local SHOWLOCATION = 3

clsHomeView = class("clsHomeView", clsBaseUI)

function clsHomeView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/HomeView.csb")
	self.ScrollView_1 = self.AreaAuto
	self.ScrollView_1:setScrollBarEnabled(false)
	self.BtnNotice:setVisible(false)
	
	ClsUIManager.GetInstance():SetNoticeWnd(self.NoticeWnd)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	local function PageViewCallBack(sender,event)
        if event == ccui.PageViewEventType.turning then
            local pageindex = self.PageView_1:getCurrentPageIndex()
            self:OnTurn2Page(pageindex)
        end
    end
    self.PageView_1:addEventListener(PageViewCallBack)
    
--	local adimage = cc.FileUtils:getInstance():fullPathForFilename("Default/wawadi.gif")
--	local cacheGif = createCacheGif(cc.FileUtils:getInstance():fullPathForFilename(adimage))
--	cacheGif:setPosition(200,300)  
--	self:addChild(cacheGif)
end

function clsHomeView:dtor()
	
end

function clsHomeView:OnShow(bShow)
	if not bShow then 
		self._redbagClosed = false 
		return 
	end
	
	KE_SetTimeout(10, function()
		proto.req_redbag_openstate()
	end)
	self:DestroyTimer("redbag_ckh")
	self:CreateAbsTimerLoop("redbag_ckh", 11, function()
		proto.req_redbag_openstate()
	end)
	
	if ClsHomeMgr.GetInstance():NeedRefreshHomeConfigData() then
		proto.req_home_homedata({show_location=SHOWLOCATION})
	end
	KE_SetTimeout(2, function()
		if ClsHomeMgr.GetInstance():NeedRefreshCaiZhongData() then
			proto.req_home_caizhong({ new_hot="1" })
		end
	end)
	if not self:HasTimer("refresh_home") then
		self:CreateAbsTimerLoop("refresh_home", 1.5, function()
			if not self:isVisible() then return true end
			local flag = true
			if not ClsHomeMgr.GetInstance():GetHomeConfigData() then
				flag = false
				proto.req_home_homedata({show_location=SHOWLOCATION})
			end
			return flag
		end)
	end
	if not self:HasTimer("refresh_caiz") then
		self:CreateAbsTimerLoop("refresh_caiz", 1, function()
			if not self:isVisible() then return true end
			local flag = true
			if not ClsHomeMgr.GetInstance():GetCaiZhongData() then
				flag = false
				proto.req_home_caizhong({ new_hot="1" })
			end
			return flag
		end)
	end
end

function clsHomeView:ForceAdapt()
    clsBaseUI.ForceAdapt(self)
    self.AreaAuto:setInnerContainerSize(self.AreaAuto:getContentSize())
	local totalHei = self.AreaAuto:getInnerContainerSize().height
	self.PageView_1:setPosition(0,totalHei)
	self.BtnNotice:setPositionY(self.PageView_1:getPositionY()-self.PageView_1:getContentSize().height)
	if self._dots then
		local totalPage = #self._dots
		for i, obj in pairs(self._dots) do
			obj:setPosition(360+(i-totalPage/2-0.5)*30, self.PageView_1:getPositionY()-self.PageView_1:getContentSize().height+20)
		end
	end
end

--注册控件事件
function clsHomeView:InitUiEvents()
	utils.RegClickEvent(self.BtnNotice, function()
		ClsUIManager.GetInstance():ShowPanel("clsAnounceView")
	end)
	utils.RegClickEvent(self.BtnRedbag, function()
		if not ClsLoginMgr.GetInstance():IsLogonSucc() then
			local function callback(mnuId)
        		if mnuId == 1 then
					ClsUIManager.GetInstance():ShowPopWnd("clsRegistUI2")
				else
					ClsUIManager.GetInstance():ShowPopWnd("clsLoginUI4")
				end
			end
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_LOGINORREGIST", 
					"提示", 
					"请登录或注册账号，再领红包",
					callback, "注册", "登录", nil, true)
			return
		end
		ClsUIManager.GetInstance():ShowPopWnd("clsRedbagOpenUI", nil, false, true)
	end)
	utils.RegClickEvent(self.BtnCloseRedbag, function()
        self.Image_1:setVisible(false)
        self._redbagClosed = true 
		--self.BtnRedbag:setVisible(false)
	end)
end

-- 注册全局事件
function clsHomeView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_home_homedata", self.on_req_home_homedata, self, true)
	--g_EventMgr:AddListener(self, "on_req_home_caizhong", self.on_req_home_caizhong, self, true)
	g_EventMgr:AddListener(self, "NET_STATE_CHANGE", function(this, bConnected)
		if bConnected then
			if not self:HasTimer("refresh_home") and not ClsHomeMgr.GetInstance():GetHomeConfigData() then
				proto.req_home_homedata({show_location=SHOWLOCATION})
			end
			if not self:HasTimer("refresh_caiz") and not ClsHomeMgr.GetInstance():GetCaiZhongData() then
				proto.req_home_caizhong({ new_hot="1" })
			end
		end
	end)
	g_EventMgr:AddListener(self, "on_req_redbag_openstate", function(this, recvdata)
		self.BtnRedbag:stopAllActions()
		if ClsRedbagMgr.GetInstance():IsOpen() or ClsRedbagMgr.GetInstance():IsWillOpen() and not self._redbagClosed then
			self.Image_1:setVisible(true)
			--self.BtnRedbag:setPosition(GAME_CONFIG.DESIGN_W-self.BtnRedbag:getContentSize().width/2-30, 250)
            self.Image_1:setPosition(GAME_CONFIG.DESIGN_W-self.BtnRedbag:getContentSize().width/2-30, 250)
            self.BtnRedbag:setRotation(0)
			self.BtnRedbag:runAction(cc.RepeatForever:create(cc.Sequence:create(
				cc.RotateBy:create(0.2, 15),
				cc.RotateBy:create(0.4, -30),
				cc.RotateBy:create(0.2, 15),
				cc.DelayTime:create(0.1)
			)))
		else
			self.Image_1:setVisible(false)
		end
	end, self)
end

function clsHomeView:on_req_home_homedata(recvdata)
	self:DestroyTimer("refresh_home")
	local pc_banner_img = ClsHomeMgr.GetInstance():GetPcBannerImg() or {}
	if pc_banner_img then
		self.PageView_1:removeAllPages()
		for idx, info in ipairs(pc_banner_img) do
			local imgSpr = ccui.ImageView:create()
			imgSpr:SetMaxSize(self.PageView_1:getContentSize().width, self.PageView_1:getContentSize().height)
			imgSpr:LoadTextureSync(info.pic)
			imgSpr:EnableTouch(function()
				ClsUIManager.GetInstance():GetWindow("clsHallUI"):SwitchTo(3)
			end)
			self.PageView_1:addPage(imgSpr)
		end
		--自动播放
		local count = #pc_banner_img
		local curIdx = 0
		self:DestroyTimer("tmr_autobf")
		self:CreateAbsTimerLoop("tmr_autobf", 5, function()
			curIdx = curIdx + 1
			if curIdx >= count then curIdx = 0 end
			self.PageView_1:scrollToPage(curIdx)
		end)
		
		self:OnTurn2Page(0, #pc_banner_img)
	end
	
	local new_notice = ClsHomeMgr.GetInstance():GetNoticeData()
--	self.lblActiveDesc:setString(new_notice and new_notice[1] and new_notice[1].title or "")
	self.lblActiveDesc:setString("")
	self.lblActiveDesc:setVisible(false)
	
	if new_notice then
		for i, str in ipairs(new_notice) do
			utils.TellNotice(new_notice[i].content)
		end
		self:DestroyTimer("renotice")
		self:CreateTimerLoop("renotice", 60*5, function()
			for i, str in ipairs(new_notice) do
				utils.TellNotice(new_notice[i].content)
			end
		end)
	end
    self:on_req_home_caizhong()
end

function clsHomeView:OnTurn2Page(idx, totalPage)
	self._dots = self._dots or {}
	if totalPage then
		for i, obj in pairs(self._dots) do 
			KE_SafeDelete(obj)
		end
		self._dots = {}
		for i=1, totalPage do
			local obj = cc.Sprite:create("uistu/games/yuan.png")
			self.ScrollView_1:addChild(obj)
			self._dots[i] = obj
			obj:setScale(18/obj:getContentSize().width)
			obj:setPosition(360+(i-totalPage/2-0.5)*30, self.PageView_1:getPositionY()-self.PageView_1:getContentSize().height+20)
		end
	end
	for i, obj in pairs(self._dots) do
		obj:setColor(cc.c3b(155,155,155))
	end
	if self._dots[idx+1] then
		self._dots[idx+1]:setColor(cc.c3b(255,255,255))
	end
end

function clsHomeView:on_req_home_caizhong(recvdata)
	self:DestroyTimer("refresh_caiz")
	local infolist = ClsHomeMgr.GetInstance():GetCaiZhongData()
    --local infolist = recvdata
	if not infolist then return end
--	logger.dump(infolist)
	self.BtnNotice:setVisible(true)
	
	local cnt = #infolist
	local COL = 3
	local ROW = math.ceil((cnt+1)/COL)
	local listHei = self.PageView_1:getContentSize().height
	local anounceHei = self.BtnNotice:getContentSize().height--+2
	local totalWid = 720
	local gridSize = totalWid / COL
    local gridSizeHei = gridSize - 30
	local btnSize = gridSize - 2
	local totalHei = math.max(listHei + anounceHei + gridSizeHei * ROW, self.ScrollView_1:getContentSize().height) + 40
	self.ScrollView_1:setInnerContainerSize(cc.size(totalWid,totalHei))
	totalHei = self.ScrollView_1:getInnerContainerSize().height
	self.PageView_1:setPosition(0,totalHei)
	self.BtnNotice:setPositionY(self.PageView_1:getPositionY()-self.PageView_1:getContentSize().height)
	local leftHei = totalHei - listHei - anounceHei - 40
	if self._dots then
		local totalPage = #self._dots
		for i, obj in pairs(self._dots) do
			obj:setPosition(360+(i-totalPage/2-0.5)*30, self.PageView_1:getPositionY()-self.PageView_1:getContentSize().height+20)
		end
	end
	
	local T_game_cfg = setting.Get("app.configs.xls.T_game_cfg")
	self._gridBtnList = self._gridBtnList or {}
	for idx=1, cnt do 
		local info = infolist[idx]
		
		local gameicon = T_game_cfg[info.id] and T_game_cfg[info.id].gameicon or info.img
		local BtnGame = self._gridBtnList[idx]
		if utils.IsValidCCObject(BtnGame) then
			BtnGame.imgGameIcon:LoadTextureSync(gameicon)
			BtnGame.lblName:setString(info.name)
            
			BtnGame.lblZhouqi:setString(info.every_time or "")
		else
			BtnGame = self:CreateGameBtn(btnSize,btnSize-30, info.name,info.every_time, gameicon)
			self.ScrollView_1:addChild(BtnGame)
		end
		self._gridBtnList[idx] = BtnGame
		
		local r = math.ceil(idx/COL)
		local c = idx%COL
		if c == 0 then c=COL end
		BtnGame:setPosition( c*gridSize-gridSize/2, leftHei-(r*gridSizeHei-gridSize/2) )
		
		utils.RegClickEvent(BtnGame, function()
			self._redbagClosed = false
			ClsGameMgr.GetInstance():OpenGame(tonumber(info.gid), info.cptype, info.name)
		end)
	end
	for j=cnt+1, #self._gridBtnList do
		KE_SafeDelete(self._gridBtnList[j])
		self._gridBtnList[j] = nil
	end
	
	--
	if not utils.IsValidCCObject(self.BtnMore) then
		self.BtnMore = self:CreateGameBtn(btnSize,btnSize-30,"更多彩种","","uistu/icon/icon_add.png")
		self.ScrollView_1:addChild(self.BtnMore)
		utils.RegClickEvent(self.BtnMore, function()
			ClsUIManager.GetInstance():GetWindow("clsHallUI"):SwitchTo(2)
		end)
	end
	local idx = cnt + 1
	local r = math.ceil(idx/COL)
	local c = idx%COL
	if c == 0 then c=COL end
	self.BtnMore:setPosition( c*gridSize-gridSize/2, leftHei-(r*gridSizeHei-gridSize/2) )
end

function clsHomeView:CreateGameBtn(wid, hei, name, every_time, img)
	local BtnGame = utils.CreateButton("uistu/common/bg_white.png","uistu/common/light_gray.jpg")
	BtnGame:setScale9Enabled(true)
	BtnGame:setContentSize(wid,hei)
	
	local lblZhouqi = utils.CreateLabel(every_time, 22)
    lblZhouqi:setAdditionalKerning(3)
	BtnGame:addChild(lblZhouqi)
	lblZhouqi:setPosition(wid/2, 35)
	lblZhouqi:setColor(cc.c3b(99,99,99))
	BtnGame.lblZhouqi = lblZhouqi
	
	local lblName = utils.CreateLabel(name, 28)
    lblName:setAdditionalKerning(5)
	BtnGame:addChild(lblName)
	lblName:setPosition(wid/2, 75)
	lblName:setColor(cc.c3b(22,22,22))
	BtnGame.lblName = lblName
	
	local imgGameIcon = ccui.ImageView:create()
	BtnGame:addChild(imgGameIcon)
	imgGameIcon:setPosition(wid/2, hei*0.66)
	BtnGame.imgGameIcon = imgGameIcon
	imgGameIcon:setScale9Enabled(false)
	imgGameIcon:setContentSize(85,85)
	imgGameIcon:ignoreContentAdaptWithSize(false)
	imgGameIcon:LoadTextureSync(img)
	
	return BtnGame
end
