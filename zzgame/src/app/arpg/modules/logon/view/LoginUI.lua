-------------------------
-- 登录界面
-------------------------
module("ui", package.seeall)

local crypto = require("kernel.framework.crypto")

clsLoginUI = class("clsLoginUI", clsBaseUI)

function clsLoginUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/LoginUI.csb")
	self.EditLogonUsername = utils.ReplaceTextField(self.EditLogonUsername)
	self.EditLogonPassword = utils.ReplaceTextField(self.EditLogonPassword)
	self.EditLogonYzm = utils.ReplaceTextField(self.EditLogonYzm)
	
	self.EditRegUserName = utils.ReplaceTextField(self.EditRegUserName)
	self.EditRegPassWord = utils.ReplaceTextField(self.EditRegPassWord)
	self.EditRegPassword2 = utils.ReplaceTextField(self.EditRegPassword2)
	self.EditRegYzm = utils.ReplaceTextField(self.EditRegYzm)
	self.EditRegYaoqm = utils.ReplaceTextField(self.EditRegYaoqm)
	self.EditRegYourName = utils.ReplaceTextField(self.EditRegYourName)
	
	self.EditRegYaoqm:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditRegUserName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassword2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYzm:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYourName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	
	self.EditLogonUsername:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditLogonPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditLogonYzm:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	
	self.EditLogonYzm:setVisible(false)
	self.EditRegYzm:setVisible(false)
	
	self.WndLogon:setPositionY(GAME_CONFIG.DESIGN_H_2+250)
	self.WndRegist:setPositionY(GAME_CONFIG.DESIGN_H_2+250+72*0.7)
	self.WndRegist:setScale(0.7)
	self.WndRegist:setLocalZOrder(0)
	self.WndLogon:setLocalZOrder(1)
	self._isLogonInTop = true

	self.EditLogonPassword:SetSensitive(true)
	self.EditRegPassWord:SetSensitive(true)
	self.EditRegPassword2:SetSensitive(true)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	local info = ClsLoginMgr.GetInstance():GetInputLoginInfo()
	self.EditLogonUsername:setString(info.username)
	self.EditLogonPassword:setString(info.pwd)
	
	local btnBanShu = ccui.Button:create()
	btnBanShu:setScale9Enabled(true)
	btnBanShu:setContentSize(200,80)
	btnBanShu:setPosition(100,1280-40)
	btnBanShu:setTitleText("版署测试")
	btnBanShu:setTitleFontSize(32)
	self:addChild(btnBanShu)
	utils.RegClickEvent(btnBanShu, function()
		ClsApp.GetInstance():runXiaoxiaole()
	end)
end

function clsLoginUI:dtor()
	
end

function clsLoginUI:Switch()
	self.WndLogon:stopAllActions()
	self.WndRegist:stopAllActions()
	self._isLogonInTop = not self._isLogonInTop
	local topWnd = self.WndLogon
	local bottomWnd = self.WndRegist
	if not self._isLogonInTop then
		topWnd = self.WndRegist
		bottomWnd = self.WndLogon
	end
	
	topWnd:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 0.85),
			cc.MoveTo:create( 0.1, cc.p(topWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+250+36*0.7) )
		),
		cc.CallFunc:create( function() topWnd:setLocalZOrder(1) end ),
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 1),
			cc.MoveTo:create( 0.1, cc.p(topWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+250) )
		)
	))
	bottomWnd:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 0.85),
			cc.MoveTo:create( 0.1, cc.p(bottomWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+250+36*0.7) )
		),
		cc.CallFunc:create( function() bottomWnd:setLocalZOrder(0) end ),
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 0.7),
			cc.MoveTo:create( 0.1, cc.p(bottomWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+250+72*0.7) )
		)
	))
end

function clsLoginUI:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnHitLogon, function() self:Switch() end)
	utils.RegClickEvent(self.BtnHitRegist, function() self:Switch() end)
	--登录
	utils.RegClickEvent(self.BtnLogon, function()
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.login)
		ClsLoginMgr.GetInstance():req_login_logon(self.EditLogonUsername:getString(), self.EditLogonPassword:getString(), self.EditLogonYzm:getString())
	end)
    utils.RegClickEvent(self.Button_1,function()
        self.EditLogonPassword:ToggleSensitive()
    end)
	--注册
	utils.RegClickEvent(self.BtnRegist, function()
		if self.EditRegPassWord:getString() ~= self.EditRegPassword2:getString() then 
			utils.TellMe("两次输入的密码不一致")
			return
		end
		
		local deviceData = SalmonUtils:getDeviceData()
		local params = {
			invite_code = self.EditRegYaoqm:getString(),
			username = self.EditRegUserName:getString(),
			pwd = self.EditRegPassWord:getString(),
			bank_name = self.EditRegYourName:getString(),
			token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() or "",
			yzm = self.EditRegYzm:getString(),
			ip = deviceData and deviceData.Ip or "",
		}
		if device.platform == "windows" then params.ip = "113.65.206.157" end
		
		if not params.username or utils.IsWhiteSpace(params.username) then
			utils.TellMe("请输入有效的用户名")
			return
		end
		if not params.pwd or utils.IsWhiteSpace(params.pwd) then
			utils.TellMe("请输入有效的密码")
			return
		end
		if not self.chkAgree:isSelected() then
			utils.TellMe("请先同意\"开户协议\"")
			return
		end
		
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.regist)
		ClsLoginMgr.GetInstance():req_login_regist(params)
	end)
	--忘记密码
	utils.RegClickEvent(self.BtnForgetSec, function()
	--	ClsUIManager.GetInstance():ShowPopWnd("clsForgetSec")
		PlatformHelper.openURLopenURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
end

-- 注册全局事件
function clsLoginUI:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_login_code",function(thisObj, recvdata)
		local cacheDir, cachePath = ClsLoginMgr.GetInstance():GetYzmPath()
		cc.Director:getInstance():getTextureCache():removeTextureForKey(cachePath)
		if not self._sprLogonYzm then
			self._sprLogonYzm = ccui.ImageView:create(cachePath)
			self.WndLogon:addChild(self._sprLogonYzm)
			self._sprLogonYzm:setPosition(75,self.EditRegYzm:getPositionY())
		else 
			self._sprLogonYzm:loadTexture(cachePath)
		end
		if not self._sprRegYzm then
			self._sprRegYzm = ccui.ImageView:create(cachePath)
			self.WndRegist:addChild(self._sprRegYzm)
			self._sprRegYzm:setPosition(75,self.EditLogonYzm:getPositionY())
		else 
			self._sprRegYzm:loadTexture(cachePath)
		end
		self.EditLogonYzm:setVisible(true)
		self.EditRegYzm:setVisible(true)
	end)
	g_EventMgr:AddListener(self,"on_req_login_regist",function(thisObj, recvdata)
		self:Switch()
	end)
end
