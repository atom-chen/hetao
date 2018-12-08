-------------------------
-- 登录管理器
--[[

流程：
第一步：
1. 请求req_home_sysinfo：获知登录是否需要验证码/注册是否需要邀请码、验证码、真实姓名
2. 请求req_login_get_token_private_key：获取token_private_key
登录：
1. 读取保存的用户名和密码，直接登录
2. 如果读取失败，进入登录界面
注册：


]]--
-------------------------
local crypto = require("kernel.framework.crypto")


ClsLoginMgr = class("ClsLoginMgr", clsCoreObject)
ClsLoginMgr.__is_singleton = true

ClsLoginMgr:RegSaveVar("token_private_key", TYPE_CHECKER.STRING_NIL)	--获取验证码需要用到
ClsLoginMgr:RegSaveVar("isNeedLoginYzm", TYPE_CHECKER.BOOL)	--是否需要登录验证码
ClsLoginMgr:RegSaveVar("isNeedRegistYzm", TYPE_CHECKER.BOOL)	--是否需要注册验证码
ClsLoginMgr:RegSaveVar("SysInfo", TYPE_CHECKER.TABLE_NIL)


function ClsLoginMgr:ctor()
	clsCoreObject.ctor(self)
	
	self._curState = const.LOGON_STATE.ready
	
	g_EventMgr:AddListener("ClsLoginMgr","on_req_login_get_token_private_key",function(thisObj, recvdata)
		if not self:IsLogonSucc() then
			if self._login_type == 1 then
				self._login_type = 0
				local info = self._stateData
				self:req_login_logon(info.username, info.pwd, info.yzm)
			elseif self._login_type == 2 then
				self._login_type = 0
				local info = table.clone(self._stateData)
				self:req_login_regist(info)
			end
		end
	end)
end

function ClsLoginMgr:dtor()
	g_EventMgr:DelListener("ClsLoginMgr")
end

function ClsLoginMgr:SetIpInfo(ipInfo)
	self._ipInfo = ipInfo
end
function ClsLoginMgr:GetIp()
	return self._ipInfo and self._ipInfo.ip or "113.111.10.83"
end

----------------------------------------------------------

function ClsLoginMgr:req_home_sysinfo()
	local apptype = "android"
	if device.platform == "ios" then
		apptype = "ios"
	end
	proto.req_home_sysinfo({app_type=apptype})
end

function ClsLoginMgr:IsHideTipLogonSucc()
	return self._bHideTipLononSucc	
end

function ClsLoginMgr:QuickLogon()
	if UserDefaultData:Get_willquicklogon(false) then
		local info = self:GetInputLoginInfo()
		if info and info.username and info.pwd then
			if info.username ~= "" and info.pwd ~= "" then
				self._bHideTipLononSucc = true
				self:req_login_logon(info.username, info.pwd, info.yzm)
				return true
			end
		end
	end
	return false
end

function ClsLoginMgr:req_login_logon(username, pwd, yzm)
	if not username or utils.IsWhiteSpace(username) then
		utils.TellMe("请输入有效的用户名")
		return
	end
	if not pwd or utils.IsWhiteSpace(pwd) then
		utils.TellMe("请输入有效的密码")
		return
	end
	if self:LoginNeedYzm() then
		if not yzm or utils.IsWhiteSpace(yzm) then
			utils.TellMe("请输入验证码")
			g_EventMgr:FireEvent("INPUT_YZM")
			return
		end
	end
	
	local params = {
		username = username,
		pwd = crypto.md5(pwd),
		code = yzm,
		token_private_key = self:Get_token_private_key(),
		--
		client_origin_pwd = pwd,
	}
	
	self:SetCurState(const.LOGON_STATE.login)
	self._stateData = table.clone(params)
	self._stateData.pwd = pwd
	self._login_type = 1
	
	if not params.token_private_key then
		proto.req_login_get_token_private_key()
		return
	end
	self._login_type = 0
	proto.req_login_logon(params)
end

function ClsLoginMgr:LoginNeedYzm()
	local SysInfo = self:Get_SysInfo()
	if SysInfo then
		return SysInfo.is_code == 1 or SysInfo.is_code == "1" or self:Get_isNeedLoginYzm()
	else
		return self:Get_isNeedLoginYzm()
	end
end

--------------------------------------------------

function ClsLoginMgr:req_login_regist(info)
	local params = {
		invite_code = info.invite_code,
		username = info.username,
		pwd = crypto.md5(info.pwd),
		bank_name = info.bank_name,
		yzm = info.yzm,
		ip = info.ip or self:GetIp(),
		token_private_key = self:Get_token_private_key(),
		from_way = const.FROMWAY,
		--
		client_origin_pwd = info.pwd,
	}
	
	if self:RegistNeedInvitecode() then
		if (not params.invite_code or utils.IsWhiteSpace(params.invite_code)) and self:IsInviteCodeMust() then
			utils.TellMe("请输入正确的邀请码")
			return
		end
	end
	if not params.username or utils.IsWhiteSpace(params.username) then
		utils.TellMe("请输入有效的用户名")
		return
	end
	if not info.pwd or utils.IsWhiteSpace(info.pwd) then
		utils.TellMe("请输入有效的密码")
		return
	end
--	if self:RegistNeedRealname() and not params.bank_name or utils.IsWhiteSpace(params.bank_name) then
--		utils.TellMe("请输入您的真实姓名")
--		return
--	end
	if self:RegistNeedYzm() then
		if not params.yzm or utils.IsWhiteSpace(params.yzm) then
			utils.TellMe("请输入验证码")
			g_EventMgr:FireEvent("INPUT_YZM")
			return
		end
	end
	
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.regist)
	self._stateData = table.clone(params)
	self._stateData.pwd = info.pwd
	self._login_type = 2
	
	if not params.token_private_key then
		proto.req_login_get_token_private_key()
		return
	end
	self._login_type = 0
	proto.req_login_regist(params)
end

function ClsLoginMgr:RegistNeedYzm()
	local SysInfo = self:Get_SysInfo()
	if SysInfo then
		return SysInfo.register_open_verificationcode == 1 or SysInfo.register_open_verificationcode == "1" or self:Get_isNeedRegistYzm()
	else
		return self:Get_isNeedRegistYzm()
	end
end

function ClsLoginMgr:RegistNeedInvitecode()
	local SysInfo = self:Get_SysInfo()
	if SysInfo then
		return SysInfo.is_agent == "1" or SysInfo.is_agent == "2" or SysInfo.is_agent == 1 or SysInfo.is_agent == 2
	else
		return true
	end
end

function ClsLoginMgr:IsInviteCodeMust()
	local SysInfo = self:Get_SysInfo()
	if SysInfo then
		return SysInfo.is_agent == 2 or SysInfo.is_agent == "2" 
	else
		return true
	end
end

function ClsLoginMgr:RegistNeedRealname()
	local SysInfo = self:Get_SysInfo()
	if SysInfo then
		return SysInfo.register_open_username == 1 or SysInfo.register_open_username == "1"
	else
		return true
	end
end

------------------------------------------------

function ClsLoginMgr:StartRefreshToken(interval)
	interval = interval or 60
    self:DestroyTimer("tmrtoken")
    self:CreateAbsTimerLoop("tmrtoken", interval, function()
		proto.req_refresh_token()
    end)
end
function ClsLoginMgr:StopRefreshToken()
    self:DestroyTimer("tmrtoken")
end 


function ClsLoginMgr:SetCurState(sState)
	assert(const.LOGON_STATE[sState])
	self._curState = sState
	if sState == const.LOGON_STATE.kicked or sState == const.LOGON_STATE.ready or sState == const.LOGON_STATE.logout then
		self._login_type = 0
        ClsStateMachine.GetInstance():ReLogin()
	end
	g_EventMgr:FireEvent("LOGIN_STATE")

    if not self:IsLogonSucc() then self:StopRefreshToken() end
end

function ClsLoginMgr:IsLogonSucc()
	return self._curState == const.LOGON_STATE.login_succ
end
function ClsLoginMgr:IsLogout()
	return self._curState == const.LOGON_STATE.logout
end

function ClsLoginMgr:GetYzmPath()
	local cacheDir = GAME_CONFIG.LOCAL_DIR .. "/imgCache"
	local cachePath = cacheDir .. "/yanzhengma.png"
	return cacheDir, cachePath
end 

function ClsLoginMgr:GetInputLoginInfo()
	return {
		username = UserDefaultData:Get_username(""),
		pwd = UserDefaultData:Get_password(""),
	}
end 
