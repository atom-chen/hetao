-------------------------
-- 我的
-------------------------
module("ui", package.seeall)

clsMineView = class("clsMineView", clsBaseUI)
function clsMineView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/MineView.csb")
	self.ListView_3 = self.AreaAuto
	self:InitUiEvents()
	self:InitGlbEvents()
	self:RefleshUI()
	proto.req_user_info()
	proto.req_user_balance()
    self.ListView_3:setScrollBarEnabled(false)
    self:SetMoneyVisible(false)
    self:RelayoutMenus()
end

function clsMineView:dtor()
	
end

function clsMineView:RelayoutMenus()
	local quickPayUrl = ClsHomeMgr.GetInstance():GetQuickPayUrl()
	local x1 = self.BtnChongZhi:getPositionX()
	local x2 = self.BtnAccountDetail:getPositionX()
	if quickPayUrl and quickPayUrl ~= "" then
		self.BtnQuickRecharge:setVisible(true)
		
		self.BtnQuickRecharge:setPositionX( x1+(x2-x1)/4 )
		self.BtnTiXian:setPositionX( x1+2*(x2-x1)/4 )
		self.BtnTouZhuJiLu:setPositionX( x1+3*(x2-x1)/4 )
	else 
		self.BtnQuickRecharge:setVisible(false)
		
		self.BtnTiXian:setPositionX( x1+(x2-x1)/3 )
		self.BtnTouZhuJiLu:setPositionX( x1+2*(x2-x1)/3 )
	end
end

--注册控件事件
function clsMineView:InitUiEvents()
	--
	utils.RegClickEvent(self.Button1, function()
		ClsUIManager.GetInstance():ShowPanel("clsMyInfoView")
	end)
	self.Head:setTitleText("")
	--
	if utils.IsValidCCObject(self.Button2) then
		utils.RegClickEvent(self.Button2, function()
		--	proto.req_agent_check_agent_register()
			ClsUIManager.GetInstance():ShowPanel("clsAgentView")
		end)
	end 
	--
	utils.RegClickEvent(self.Button3, function()
		ClsUIManager.GetInstance():ShowPanel("clsTodayEarn")
	end)
	--
	utils.RegClickEvent(self.Button4, function()
		ClsUIManager.GetInstance():ShowPanel("clsAnounceView")
	end)
	--
	utils.RegClickEvent(self.Button5, function()
		ClsUIManager.GetInstance():ShowPanel("clsRechargeRecord")
	end)
	
	--
	utils.RegClickEvent(self.Button6, function()
		ClsUIManager.GetInstance():ShowPanel("clsWithdrawRecord")
	end)
	--
	utils.RegClickEvent(self.Button7, function()
		ClsUIManager.GetInstance():ShowPanel("clsCollectView")
	end)
	--
	utils.RegClickEvent(self.Button8, function()
		ClsUIManager.GetInstance():ShowPanel("clsSafeView")
	end)
	--
	utils.RegClickEvent(self.Button9, function()
		ClsUIManager.GetInstance():ShowPanel("clsSetterView")
	end)
	
	--
	utils.RegClickEvent(self.BtnAccountDetail, function()
		ClsUIManager.GetInstance():ShowPanel("clsAccountDetail")
	end)
	--
	utils.RegClickEvent(self.BtnChongZhi, function()
        ClsUIManager.GetInstance():ShowPanel("clsRechargeRecharge")
		--ClsUIManager.GetInstance():ShowPanel("clsRecharge22View")
	end)

    utils.RegClickEvent(self.BtnTouZhuJiLu,function()
        ClsUIManager.GetInstance():ShowPanel("clsBetHistoryView")
    end)
    utils.RegClickEvent(self.BtnTiXian,function()
    	proto.req_user_tixian()
    end)
    utils.RegClickEvent(self.BtnQuickRecharge,function()
    	PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetQuickPayUrl())
    end)

    utils.RegClickEvent(self.Head,function()
        ClsUIManager.GetInstance():ShowPanel("clsMyInfoView")
    end)

    utils.RegClickEvent(self.BtnBalance,function()
    	self:SetMoneyVisible(not self.bMoneyVisible)
    	if self.bMoneyVisible then
			proto.req_user_balance()
    	end
    end)
end

function clsMineView:SetMoneyVisible(bVisible)
	self.bMoneyVisible = bVisible
	if self.bMoneyVisible then
		local userObj = UserEntity.GetInstance()
		self.lblBalance:setString("余额："..(userObj:Get_balance() or "0"))
		self.lblBalance:setTextColor(cc.c3b(51,51,51))
	else
		self.lblBalance:setString("余额：*******")
		self.lblBalance:setTextColor(cc.c3b(153,153,153))
	end
	local x = math.max(210, self.lblBalance:getPositionX()+self.lblBalance:getContentSize().width/g_ContentScaleFactor+30)
	self.eye_see:setPositionX(x)
	self.eye_unsee:setPositionX(x)
	self.eye_see:setVisible(bVisible)
	self.eye_unsee:setVisible(not bVisible)
end

-- 注册全局事件
function clsMineView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_home_homedata", function(thisObj, recvData)
		self:RelayoutMenus()
	end)
	g_EventMgr:AddListener(self, "on_req_user_info", self.RefleshUI, self)
	g_EventMgr:AddListener(self, "on_req_user_balance", self.RefleshUI, self)
	g_EventMgr:AddListener(self, "on_req_user_tixian", function(thisObj, recvdata)
		if not recvdata or not recvdata.data then return end 
		local data = recvdata
		proto.req_pay_withdraw_type({money=tostring(recvdata.data.out_min)}, nil, function(recvdata)
			if recvdata then
				if proto.is_success(recvdata) then
					KE_SetTimeout(1, function()
						ClsUIManager.GetInstance():ShowPanel("clsWithdrawView"):RefleshUI(data)
					end)
				else
					if type(recvdata) == "table" then
						if recvdata.code == 429 then
							ClsUIManager.GetInstance():PopConfirmDlg("CFM_BIND_BANK", "提示", "请第一时间绑定收款方式\n \n请绑定收款账号", function(mnuId)
								if mnuId == 1 then
									ClsUIManager.GetInstance():ShowPanel("clsPayCenter")
								end
							end) 
						end
					end
				end
			end
		end)
	end, self)
--	g_EventMgr:AddListener(self, "on_req_agent_check_agent_register", function(thisObj, recvdata)
--		ClsUIManager.GetInstance():ShowPanel("clsAgentView")
--	end)
end

--刷新界面
function clsMineView:RefleshUI(recvdata)
	local userObj = UserEntity.GetInstance()
	self.lblName:setString(userObj:Get_username() or "")
	--self.lblBalance:setString("余额："..(userObj:Get_balance() or "0"))
    self.lblBalance:setString("余额：*******")
	self.HeadIcon:SetMaxSize(100,100)
	self.HeadIcon:SetHeadImg(userObj:Get_img(), true, userObj:Get_dengji())
	self.BtnVip:setTitleText( string.format("VIP%d",userObj:Get_dengji() or 0) )
	self.BtnVip:setPositionX(self.lblName:getPositionX()+self.lblName:getContentSize().width/g_ContentScaleFactor+10)
	self:SetMoneyVisible(self.bMoneyVisible)
	
	if not userObj:IsAgent() then
		if utils.IsValidCCObject(self.Button2) then
			self.ListView_3:removeItem(self.ListView_3:getIndex(self.Button2))
		end
	end
end
