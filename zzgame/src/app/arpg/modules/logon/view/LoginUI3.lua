-------------------------
-- 登录界面
-------------------------
module("ui", package.seeall)

local crypto = require("kernel.framework.crypto")
local YOFFSET = 345

clsLoginUI3 = class("clsLoginUI3", clsBaseUI)

function clsLoginUI3:ctor(parent, iTopWnd)
	clsBaseUI.ctor(self, parent, "uistu/LoginUI3.csb")
	self.EditLogonUsername = utils.ReplaceTextField(self.EditLogonUsername,"","FF111111")
	self.EditLogonPassword = utils.ReplaceTextField(self.EditLogonPassword,"","FF111111")
	self.EditLogonYzm = utils.ReplaceTextField(self.EditLogonYzm,"","FF111111")
	
	self.EditRegUserName = utils.ReplaceTextField(self.EditRegUserName,"","FF111111")
	self.EditRegPassWord = utils.ReplaceTextField(self.EditRegPassWord,"","FF111111")
	self.EditRegPassword2 = utils.ReplaceTextField(self.EditRegPassword2,"","FF111111")
	self.EditRegYzm = utils.ReplaceTextField(self.EditRegYzm,"","FF111111")
	self.EditRegYaoqm = utils.ReplaceTextField(self.EditRegYaoqm,"","FF111111")
	self.EditRegYourName = utils.ReplaceTextField(self.EditRegYourName,"","FF111111")
	
	self.EditRegYaoqm:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditRegUserName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassword2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYzm:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYourName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	
	self.EditLogonUsername:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditLogonPassword:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditLogonYzm:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)

	self.BtnEyePwd:getChildByName("eyesee"):setVisible(self.EditRegPassWord:IsSensitive())
    self.BtnEyePwd:getChildByName("eyeclose"):setVisible(not self.EditRegPassWord:IsSensitive())
    self.BtnEyeRepwd:getChildByName("eyesee"):setVisible(self.EditRegPassword2:IsSensitive())
	self.BtnEyeRepwd:getChildByName("eyeclose"):setVisible(not self.EditRegPassword2:IsSensitive())
    self.BtnEyePwd_1:getChildByName("eyesee"):setVisible(self.EditLogonPassword:IsSensitive())
    self.BtnEyePwd_1:getChildByName("eyeclose"):setVisible(not self.EditLogonPassword:IsSensitive())

	self.LoginPanelYzm:setVisible(false)
	--self.PanelYzm:setVisible(false)
	
	self._isLogonInTop = false
	self:Switch(true)

	self.EditLogonPassword:SetSensitive(true)
	self.EditRegPassWord:SetSensitive(true)
	self.EditRegPassword2:SetSensitive(true)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	if iTopWnd and iTopWnd == 2 then
        self:Switch()
    end
    
    if ClsLoginMgr.GetInstance():IsLogout() then
    --	self.EditLogonUsername:setString("")
	--	self.EditLogonPassword:setString("")
    else
	--	local info = ClsLoginMgr.GetInstance():GetInputLoginInfo()
	--	self.EditLogonUsername:setString(info.username)
	--	self.EditLogonPassword:setString(info.pwd)
	end
	
    ClsLoginMgr.GetInstance():req_home_sysinfo()
    self:LoginAdd()
    self:RegisterAdd()
    
    proto.req_get_ipinfo()
end

function clsLoginUI3:ForceAdapt()
    clsBaseUI.ForceAdapt(self)
end
function clsLoginUI3:LoginIsNeedYzm()
    return ClsLoginMgr.GetInstance():LoginNeedYzm()
end
function clsLoginUI3:RegisterIsNeedYzm()
    return ClsLoginMgr.GetInstance():RegistNeedYzm()
end
function clsLoginUI3:dtor()
	
end

function clsLoginUI3:Switch(bSkipAni)
	local botScale = 0.6
	self.WndLogon:stopAllActions()
	self.WndRegist:stopAllActions()
	self._isLogonInTop = not self._isLogonInTop
	local topWnd = self.WndLogon
	local bottomWnd = self.WndRegist
	if not self._isLogonInTop then
		topWnd = self.WndRegist
		bottomWnd = self.WndLogon
	end
	
	if bSkipAni then
		topWnd:setScale(1)
		topWnd:setPositionY(GAME_CONFIG.DESIGN_H_2+YOFFSET)
		bottomWnd:setScale(botScale)
		bottomWnd:setPositionY(GAME_CONFIG.DESIGN_H_2+YOFFSET+80*botScale)
		topWnd:setLocalZOrder(1)
		bottomWnd:setLocalZOrder(0)
		return
	end
	
	topWnd:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, botScale),
			cc.MoveTo:create( 0.1, cc.p(topWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+YOFFSET+40*botScale) )
		),
		cc.CallFunc:create( function() topWnd:setLocalZOrder(1) end ),
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 1),
			cc.MoveTo:create( 0.1, cc.p(topWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+YOFFSET) )
		)
	))
	bottomWnd:runAction(cc.Sequence:create(
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, 1),
			cc.MoveTo:create( 0.1, cc.p(bottomWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+YOFFSET+40*botScale) )
		),
		cc.CallFunc:create( function() bottomWnd:setLocalZOrder(0) end ),
		cc.Spawn:create(
			cc.ScaleTo:create(0.1, botScale),
			cc.MoveTo:create( 0.1, cc.p(bottomWnd:getPositionX(), GAME_CONFIG.DESIGN_H_2+YOFFSET+80*botScale) )
		)
	))
end

function clsLoginUI3:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnHitLogon, function() self:Switch() end)
	utils.RegClickEvent(self.BtnHitRegist, function() self:Switch() end)
    utils.RegClickEvent(self.BtnHitRegist_0, function() self:Switch() end)
    utils.RegClickEvent(self.BtnChange, function() self:Switch() end)
    utils.RegClickEvent(self.BtnEyePwd,function()
        self.EditRegPassWord:ToggleSensitive()
        self.BtnEyePwd:getChildByName("eyesee"):setVisible(not self.EditRegPassWord:IsSensitive())
        self.BtnEyePwd:getChildByName("eyeclose"):setVisible(self.EditRegPassWord:IsSensitive())
    end)
    utils.RegClickEvent(self.BtnEyeRepwd,function()
        self.EditRegPassword2:ToggleSensitive()
        self.BtnEyeRepwd:getChildByName("eyesee"):setVisible(not self.EditRegPassword2:IsSensitive())
        self.BtnEyeRepwd:getChildByName("eyeclose"):setVisible(self.EditRegPassword2:IsSensitive())
    end)
    utils.RegClickEvent(self.BtnEyePwd_1,function()
        self.EditLogonPassword:ToggleSensitive()
        self.BtnEyePwd_1:getChildByName("eyesee"):setVisible(not self.EditLogonPassword:IsSensitive())
        self.BtnEyePwd_1:getChildByName("eyeclose"):setVisible(self.EditLogonPassword:IsSensitive())
    end)
    --[[
    self.EditLogonUsername:registerScriptEditBoxHandler(function(evenName, sender)
		if evenName == "changed" then
			local allusers = UserDefaultData:Get_allusers({}) or {}
			local name = self.EditLogonUsername:getString()
			if allusers[name] then
				self.EditLogonPassword:setString(allusers[name])
			else 
				self.EditLogonPassword:setString("")
			end
			self.EditLogonPassword:SetSensitive(self.EditLogonPassword:IsSensitive())
		end
	end)
	]]--
	--登录
	utils.RegClickEvent(self.BtnLogon, function()
        if utils.IsWhiteSpace(self.EditLogonPassword:getString()) then
            utils.TellMe("密码不可为空!")
        else
		    ClsLoginMgr.GetInstance():req_login_logon(self.EditLogonUsername:getString(), self.EditLogonPassword:getString(), self.EditLogonYzm:getString())
        end
	end)

	--注册
	utils.RegClickEvent(self.BtnRegist, function()
        if string.len(self.EditRegPassWord:getString())<6 or string.len(self.EditRegPassWord:getString())>12 then 
            utils.TellMe("请输入6~12位的密码")
			return
        end
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
			ip = deviceData and deviceData.Ip or PlatformHelper:GetIpAddress(),
		}
		if device.platform == "windows" then params.ip = "113.65.206.157" end
		if device.platform == "ios" then params.ip = nil end
		
        if not params.invite_code or utils.IsWhiteSpace(params.invite_code) then
            utils.TellMe("邀请码不可为空")
            return
        end
		if not params.username or utils.IsWhiteSpace(params.username) then
			utils.TellMe("请输入有效的账号")
			return
		end
        if string.len(params.username)<4 or string.len(params.username)>14 then
            utils.TellMe("会员账号必须为4~14位字符")
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
		
		ClsLoginMgr.GetInstance():req_login_regist(params)
	end)

	--忘记密码
	utils.RegClickEvent(self.BtnForgetSec, function()
	--	ClsUIManager.GetInstance():ShowPopWnd("clsForgetSec")
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
    utils.RegClickEvent(self.BtnRegAgree, function()
		self.chkAgree:setSelected(not self.chkAgree:isSelected())
	end)
    self.ImgLoginYzm:EnableTouch(function()
		if ClsLoginMgr.GetInstance():Get_token_private_key() then 
			proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
		else
			proto.req_login_get_token_private_key(nil,nil,function()
				if ClsLoginMgr.GetInstance():Get_token_private_key() then
					proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
				end
			end)
		end
	end)
    self.ImgRegistYzm:EnableTouch(function()
		if ClsLoginMgr.GetInstance():Get_token_private_key() then 
			proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
		else
			proto.req_login_get_token_private_key(nil,nil,function()
				if ClsLoginMgr.GetInstance():Get_token_private_key() then
					proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
				end
			end)
		end
	end)
end

-- 注册全局事件
function clsLoginUI3:InitGlbEvents()
    g_EventMgr:AddListener(self,"on_req_login_code",function(thisObj, recvdata)
		self:LoginAdd()
        self:RegisterAdd()
	end)
	
	g_EventMgr:AddListener(self,"fail_req_login_code",function(thisObj, recvdata)
--		utils.TellMe("验证码拉取失败，请手动刷新")
		self:LoginAdd()
        self:RegisterAdd()
	end)
	
	g_EventMgr:AddListener(self,"error_req_login_code",function(thisObj, recvdata)
--		utils.TellMe("验证码拉取失败，请手动刷新")
		self:LoginAdd()
	end)
	
	g_EventMgr:AddListener(self,"fail_req_login_logon",function(thisObj, recvdata)
		if ClsLoginMgr.GetInstance():Get_token_private_key() then 
			proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
		else
			proto.req_login_get_token_private_key(nil,nil,function(RecvData2)
				if ClsLoginMgr.GetInstance():Get_token_private_key() then
					proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
				end
			end)
		end
		self:LoginAdd()
	end)
    g_EventMgr:AddListener(self, "on_req_login_logon", function(this, recvdata)
		self:removeSelf()
	end)
	g_EventMgr:AddListener(self,"fail_req_login_regist",function(thisObj, recvdata)
		if ClsLoginMgr.GetInstance():RegistNeedYzm() then 
			if ClsLoginMgr.GetInstance():Get_token_private_key() then 
				proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
			else
				proto.req_login_get_token_private_key(nil,nil,function(RecvData2)
					if ClsLoginMgr.GetInstance():Get_token_private_key() then
						proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
					end
				end)
			end
		end
		self:RegisterAdd()
	end)
	g_EventMgr:AddListener(self,"on_req_home_sysinfo",function(thisObj, recvdata)
		if ClsLoginMgr.GetInstance():LoginNeedYzm() or ClsLoginMgr.GetInstance():RegistNeedYzm() then
			if ClsLoginMgr.GetInstance():Get_token_private_key() then 
				proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
			else
				proto.req_login_get_token_private_key(nil,nil,function(RecvData2)
					if ClsLoginMgr.GetInstance():Get_token_private_key() then
						proto.req_login_code({ token_private_key = ClsLoginMgr.GetInstance():Get_token_private_key() }) 
					end
				end)
			end
		end
		self:LoginAdd()
        self:RegisterAdd()
	end)
	g_EventMgr:AddListener(self,"on_req_login_regist",function(thisObj, recvdata)
		self:Switch()
	end)
    g_EventMgr:AddListener(self, "INPUT_YZM", function(this)
		self:LoginAdd()
        self:RegisterAdd()
	end)
end

function clsLoginUI3:LoginAdd()
    local options = {
		{ comp = self.LoginPanelYzm, 		checker = function() return ClsLoginMgr.GetInstance():LoginNeedYzm() end },
		{ comp = self.LoginPanelPwd, 		checker = function() return true end },
		{ comp = self.LoginPanelUsername, 	checker = function() return true end },
	}
	
	local curY = 200
	local count = 0
	for idx, info in ipairs(options) do
		local curOpt = options[idx]
		if curOpt.checker() then
			count = count + 1
			curOpt.comp:setVisible(true)
			curOpt.comp:setPositionY(curY+(count-1)*100)
		else
			curOpt.comp:setVisible(false)
		end
	end
	local h = curY+(count-1)*100 + 130
	self.WndLogon:setContentSize(self.WndLogon:getContentSize().width, h)
	self.BtnHitLogon:setPositionY(h+2)
	self.lblLogonTitle:setPositionY(h-35)
	
	if self:LoginIsNeedYzm() then
		local cacheDir, cachePath = ClsLoginMgr.GetInstance():GetYzmPath()
		cc.Director:getInstance():getTextureCache():removeTextureForKey(cachePath)
		self.ImgLoginYzm:loadTexture(cachePath)
	end
end

function clsLoginUI3:RegisterAdd()
    local options = {
		{ comp = self.PanelYzm, 		checker = function() return ClsLoginMgr.GetInstance():RegistNeedYzm() end },
		{ comp = self.PanelRealName, 	checker = function() return ClsLoginMgr.GetInstance():RegistNeedRealname() end },
		{ comp = self.PanelRePwd, 		checker = function() return true end },
		{ comp = self.PanelPwd, 		checker = function() return true end },
		{ comp = self.PanelUsername, 	checker = function() return true end },
		{ comp = self.PanelYqm, 		checker = function() return ClsLoginMgr.GetInstance():RegistNeedInvitecode() end },
	}
	
	local curY = 220
	local count = 0
	for idx, info in ipairs(options) do
		local curOpt = options[idx]
		if curOpt.checker() then
			count = count + 1
			curOpt.comp:setVisible(true)
			curOpt.comp:setPositionY(curY+(count-1)*90)
		else
			curOpt.comp:setVisible(false)
		end
	end
	local h = curY+(count-1)*90 + 120
	self.WndRegist:setContentSize(self.WndRegist:getContentSize().width, h)
	self.ImageBbs:setContentSize(self.ImageBbs:getContentSize().width, h)
	self.BtnHitRegist:setPositionY(h+2)
	self.lblRegTitle:setPositionY(h-35)
	
	if self:RegisterIsNeedYzm() then
		local cacheDir, cachePath = ClsLoginMgr.GetInstance():GetYzmPath()
		cc.Director:getInstance():getTextureCache():removeTextureForKey(cachePath)
		self.ImgRegistYzm:loadTexture(cachePath)
	end
    if ClsLoginMgr.GetInstance():IsInviteCodeMust() then
        self.ismust:setVisible(true)
    else
        self.ismust:setVisible(false)
    end
end
