-------------------------
-- 大厅
-------------------------
module("ui", package.seeall)

local PAGE_CFG = {
	[1] = {
		Desc = "首页",
		Title = "易彩云",
		ViewClass = "clsHomeView"
	},
	[2] = {
		Desc = "购彩",
		Title = "购彩大厅",
		ViewClass = "clsGouCaiView"
	},
	[3] = {
		Desc = "活动",
		Title = "活动中心",
        ViewClass = "clsActiveView"
	},
	[4] = {
		Desc = "发现",
		Title = "发现",
        ViewClass = "clsFindView"
	},
	[5] = {
		Desc = "我的",
		Title = "个人中心",
		ViewClass = "clsMineView"
	},
}

local LOGOSCALE = 0.5

clsHallUI = class("clsHallUI", clsBaseUI)

function clsHallUI:ctor(parent, argInfo)
	clsBaseUI.ctor(self, parent, "uistu/HallUI.csb")
	self.Button_Service:setVisible(false)
	if CUR_SITE_NAME == "aicai" then LOGOSCALE = 1 end
	self.ImgLogo:setScale(LOGOSCALE)
	self._subViews = {}
	self._tabBtns = { self.BtnShouYe, self.BtnGouCai, self.BtnHuoDong, self.BtnFaXian, self.BtnWoDe }
	self:InitGlbEvents()
	self:InitUiEvents()
	self:SwitchTo(1)
	self.BtnRegist:setVisible(false)
	
	if not ClsGameMgr.GetInstance():GetAllGameInfo() then
		proto.req_goucai_all_games({use="all"})
	end
	ClsGameLhcMgr.GetInstance():ReqLhcSxData()
end

function clsHallUI:dtor()
	
end

-- 注册全局事件
function clsHallUI:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_home_homedata", self.on_req_home_homedata, self, true)
	g_EventMgr:AddListener(self, "LOGIN_STATE", function() self:RefleshLogonBtn() end)
end

function clsHallUI:on_req_home_homedata(recvdata)
	local logo = ClsHomeMgr.GetInstance():GetLogoImg()
	if not logo then return end
	self.ImgLogo:SetLoadedCallback(function()
		if self._curPageIdx == 1 then
			self.LblTitle:setVisible(false)
		end
	end)
	self.ImgLogo:setScale9Enabled(false)
	self.ImgLogo:ignoreContentAdaptWithSize(true)
	self.ImgLogo:LoadTextureSync(logo)
	self.ImgLogo:setScale(LOGOSCALE)
    local nhddt = ClsHomeMgr.GetInstance():GetHddt()
    if not nhddt then return end
    if nhddt and nhddt == "1" or nhddt == 1 then
        PAGE_CFG[4].Desc = "活动大厅"
        PAGE_CFG[4].Title = "活动大厅"
        PAGE_CFG[4].ViewClass = nil
        self.Text_5:setString("活动大厅")
    end
--	PlatformHelper.openURL(logo)
end

function clsHallUI:_swith_to(pageIdx)
	self._curPageIdx = pageIdx
	local Info = PAGE_CFG[pageIdx]
	self.LblTitle:setString(Info.Title)
	self.ImgLogo:setVisible(pageIdx==1)
	self.Button_Service:setVisible(pageIdx==5)
	self:RefleshLogonBtn()
	self.LblTitle:setVisible(pageIdx~=1)
	
	for i=1, 5 do
		local objlist = self._tabBtns[i]:getChildren()
		if i ~= pageIdx then
			for _, obj in pairs(objlist) do
				obj:setColor(cc.c3b(255,255,255))
			end
		else
			for _, obj in pairs(objlist) do
				obj:setColor(cc.c3b(255,0,0))
			end
		end
	end
	
	for i, subView in pairs(self._subViews) do
		if i ~= pageIdx then
			KE_SafeDelete(subView)
			self._subViews[i] = nil
		end
	end
	
	if Info.ViewClass then
		if utils.IsValidCCObject(self._subViews[pageIdx]) then
			self._subViews[pageIdx]:setVisible(true)
		else
			self._subViews[pageIdx] = ui[Info.ViewClass].new()
			self.BgSubArea:addChild(self._subViews[pageIdx])
		end
		if self._subViews[pageIdx].OnShow then
			self._subViews[pageIdx]:OnShow(true)
		end
    else
        print("okokokokokok我去聊天室了")
        ModuleUtil.EnterModule(ModuleUtil.dragon)
--        if device.platform ~= "windows" then
--    	    local webView = ccexp.WebView:create()
--    	    self:addChild(webView)
--    	    webView:setContentSize(720,1190)
--    	    webView:setAnchorPoint(cc.p(0,0))
--    	    webView:loadURL()
--	    else
--    	    PlatformHelper.openURL()
--	    end
	end
end

function clsHallUI:SwitchTo(pageIdx)
	if pageIdx <= 4 then
		self.aborded = true
		self:_swith_to(pageIdx)
	else
		self.aborded = false
		if UserEntity.GetInstance():Get_type() then
			self:_swith_to(pageIdx)
		else
			proto.req_user_balance(nil,nil,function(recvdata)
				if recvdata and recvdata.data and not self.aborded then
					self:_swith_to(pageIdx)
				end
			end)
		end
	end
end 

function clsHallUI:RefleshLogonBtn()
	local pageIdx = self._curPageIdx
	local bLoginSucc = ClsLoginMgr.GetInstance():IsLogonSucc()
	self.BtnLogin:setVisible(pageIdx==1 and not bLoginSucc)
	self.BtnRegist:setVisible(false)
end

function clsHallUI:InitUiEvents()
	--首页
	utils.RegClickEvent(self.BtnShouYe, function()
		self:SwitchTo(1)
	end)
	--购彩
	utils.RegClickEvent(self.BtnGouCai, function()
		self:SwitchTo(2)
	end)
	--活动
	utils.RegClickEvent(self.BtnHuoDong, function()
		self:SwitchTo(3)
	end)
	--发现
	utils.RegClickEvent(self.BtnFaXian, function()
		self:SwitchTo(4)
	end)
	--我的
	utils.RegClickEvent(self.BtnWoDe, function()
		self:SwitchTo(5)
	end)
	
	--客服
	utils.RegClickEvent(self.Button_Service,function()
	--	ClsUIManager.GetInstance():ShowPanel("clsCustomerSerView")
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
	
	--登录
	utils.RegClickEvent(self.BtnLogin, function()
		ClsUIManager.GetInstance():ShowPopWnd("clsLoginUI4")
	end)
	--注册
	utils.RegClickEvent(self.BtnRegist, function()
		ClsUIManager.GetInstance():ShowPopWnd("clsRegistUI2")
	end)
end
