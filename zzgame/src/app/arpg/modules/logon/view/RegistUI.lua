-------------------------
-- 登录界面
-------------------------
module("ui", package.seeall)

local crypto = require("kernel.framework.crypto")

clsRegistUI = class("clsRegistUI", clsBaseUI)

function clsRegistUI:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RegistUI.csb")
	self.WndRegist:setPositionY(self.AreaAuto:getContentSize().height/2+45)
	self.PanelRed:setContentSize(self.PanelRed:getContentSize().width, self.AreaAuto:getContentSize().height/2-45)
	
	self.EditRegUserName = utils.ReplaceTextField(self.EditRegUserName,"uistu/common/null.png","BLACK")
	self.EditRegPassWord = utils.ReplaceTextField(self.EditRegPassWord,"uistu/common/null.png","BLACK")
	self.EditRegPassword2 = utils.ReplaceTextField(self.EditRegPassword2,"uistu/common/null.png","BLACK")
	self.EditRegYzm = utils.ReplaceTextField(self.EditRegYzm,"uistu/common/null.png","BLACK")
	self.EditRegYaoqm = utils.ReplaceTextField(self.EditRegYaoqm,"uistu/common/null.png","BLACK")
	self.EditRegYourName = utils.ReplaceTextField(self.EditRegYourName,"uistu/common/null.png","BLACK")
	
	self.EditRegYaoqm:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
	self.EditRegUserName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassWord:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegPassword2:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYzm:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	self.EditRegYourName:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
	
	self.PanelYqm._originY = self.PanelYqm:getPositionY()
	self.PanelUsername._originY = self.PanelUsername:getPositionY()
	self.PanelPwd._originY = self.PanelPwd:getPositionY()
	self.PanelRePwd._originY = self.PanelRePwd:getPositionY()
	self.PanelRealName._originY = self.PanelRealName:getPositionY()
	self.PanelYzm._originY = self.PanelYzm:getPositionY()
	self.BtnRegist._originY = self.BtnRegist:getPositionY()
	self.BtnRegAgree._originY = self.BtnRegAgree:getPositionY()
	self.chkAgree._originY = self.chkAgree:getPositionY()

	self.EditRegPassWord:SetSensitive(true)
	self.EditRegPassword2:SetSensitive(true)
	self.BtnEyePwd:getChildByName("eyesee"):setVisible(not self.EditRegPassWord:IsSensitive())
    self.BtnEyePwd:getChildByName("eyeclose"):setVisible(self.EditRegPassWord:IsSensitive())
    self.BtnEyeRepwd:getChildByName("eyesee"):setVisible(not self.EditRegPassword2:IsSensitive())
	self.BtnEyeRepwd:getChildByName("eyeclose"):setVisible(self.EditRegPassword2:IsSensitive())
	
	self:AdjustUI()
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	ClsLoginMgr.GetInstance():req_home_sysinfo()
end

function clsRegistUI:dtor()
	
end

function clsRegistUI:AdjustUI()
	local options = {
		{ comp = self.PanelYzm, 		checker = function() return ClsLoginMgr.GetInstance():RegistNeedYzm() end },
		{ comp = self.PanelRealName, 	checker = function() return ClsLoginMgr.GetInstance():RegistNeedRealname() end },
		{ comp = self.PanelRePwd, 		checker = function() return true end },
		{ comp = self.PanelPwd, 		checker = function() return true end },
		{ comp = self.PanelUsername, 	checker = function() return true end },
		{ comp = self.PanelYqm, 		checker = function() return ClsLoginMgr.GetInstance():RegistNeedInvitecode() end },
	}
	
	local curY = 288
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
	local h = curY+(count-1)*100 + 72
	self.WndRegist:setContentSize(self.WndRegist:getContentSize().width, h)
	self.WndRegist:setPositionY(self.AreaAuto:getContentSize().height/2+45)
	self.ImageBbs:setContentSize(self.ImageBbs:getContentSize().width, h)
	
	if self:IsNeedYzm() then
		local cacheDir, cachePath = ClsLoginMgr.GetInstance():GetYzmPath()
		cc.Director:getInstance():getTextureCache():removeTextureForKey(cachePath)
		self.ImgRegistYzm:loadTexture(cachePath)
	end
end

function clsRegistUI:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	
	utils.RegClickEvent(self.BtnRegAgree, function()
		self.chkAgree:setSelected(not self.chkAgree:isSelected())
	end)
	
	utils.RegClickEvent(self.BtnLogon, function()
		self:removeSelf()
		ClsUIManager.GetInstance():ShowPopWnd("clsLoginUI2")
	end)
	
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
		params.client_origin_pwd = params.pwd
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
		
		ClsLoginMgr.GetInstance():req_login_regist(params)
	end)
end

function clsRegistUI:IsNeedYzm()
	return ClsLoginMgr.GetInstance():RegistNeedYzm()
end

-- 注册全局事件
function clsRegistUI:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_login_code",function(thisObj, recvdata)
		self:AdjustUI()
	end)
	
	g_EventMgr:AddListener(self,"fail_req_login_code",function(thisObj, recvdata)
--		utils.TellMe("验证码拉取失败，请手动刷新")
		self:AdjustUI()
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
		self:AdjustUI()
	end)
	
	g_EventMgr:AddListener(self,"on_req_home_sysinfo",function(thisObj, recvdata)
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
		self:AdjustUI()
	end)
	
	g_EventMgr:AddListener(self,"on_req_login_regist",function(thisObj, recvdata, tArgs)
		self:removeSelf()
	end)
	
	g_EventMgr:AddListener(self, "INPUT_YZM", function(this)
		self:AdjustUI()
	end)
end
