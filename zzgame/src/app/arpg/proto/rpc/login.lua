-------------------------
-- 登录协议
-------------------------
module("proto",package.seeall)

local crypto = require("kernel.framework.crypto")

function on_req_get_ipinfo(recvdata)
	if recvdata and recvdata.data then
		ClsLoginMgr.GetInstance():SetIpInfo(recvdata.data)
	end
end
function fail_req_get_ipinfo(recvdata)
	if recvdata and recvdata.data then
		ClsLoginMgr.GetInstance():SetIpInfo(recvdata.data)
	end
end

--是否可注册
function on_req_login_can_regist()
	
end

--系统信息
function on_req_home_sysinfo(recvdata, tArgs)
	if not recvdata then return end
	ClsLoginMgr.GetInstance():Set_SysInfo(recvdata.data)
end

--获取token_private_key
function on_req_login_get_token_private_key(recvdata)
	if recvdata and recvdata.data then
		ClsLoginMgr.GetInstance():Set_token_private_key(recvdata.data.token_private_key)
	end
end

--登录
function on_req_login_logon(recvdata, tArgs)
	HttpUtil.token = recvdata.data.token
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.login_succ)
	if recvdata.code == 200 then
        ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(false)
    end
	--初始化UserEntity
	UserEntity.DelInstance()
	UserEntity.GetInstance():BatchSetAttr(recvdata.data)
	
	--缓存登录密码
	UserDefaultData:Set_willquicklogon(true)
	UserDefaultData:Set_username(UserEntity.GetInstance():Get_username())
	UserDefaultData:Set_password(tArgs.client_origin_pwd or "")
	local allusers = UserDefaultData:Get_allusers({})
	allusers[UserEntity.GetInstance():Get_username()] = tArgs.client_origin_pwd or ""
	UserDefaultData:Set_allusers(allusers)
	
	--进入游戏
	ClsStateMachine.GetInstance():ToStateGameing()
	KE_SetTimeout(5, function() 
		if not ClsLoginMgr.GetInstance():IsHideTipLogonSucc() then
			utils.TellMe("登录成功") 
		end
		proto.req_get_game_article_content({id="68"})
		UserDbCache.GetInstance():InitAllUserData()
	end)
    ClsLoginMgr.GetInstance():StartRefreshToken()
end 

function fail_req_login_logon(recvdata)
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.login_fail)
	if recvdata and recvdata.code == 425 then
		ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(true)
	end
end

function error_req_login_logon(recvdata)
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.login_fail)
	utils.TellMe("登录失败")
end

--注册
function on_req_login_regist(recvdata, tArgs)
	if recvdata and recvdata.data then
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.regist_succ)
		UserEntity.GetInstance():BatchSetAttr(recvdata.data)
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.login)
		ClsLoginMgr.GetInstance():req_login_logon(tArgs.username, tArgs.client_origin_pwd)
	end
	KE_SetTimeout(2, function() 
		utils.TellMe("注册成功")
	end)
end

function fail_req_login_regist(recvdata)
--	utils.TellMe("注册失败")
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.regist_fail)
	if recvdata and recvdata.code == 425 then
		ClsLoginMgr.GetInstance():Set_isNeedRegistYzm(true)
	end
end

function error_req_login_regist(recvdata)
	ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.regist_fail)
	utils.TellMe("注册失败")
end

function on_req_login_logout(recvdata)
    
end

--验证码图片
function on_req_login_code(recvdata)
	if not recvdata then 
		utils.TellMe("获取验证码失败")
		return 
	end
	
	local cacheDir, cachePath = ClsLoginMgr.GetInstance():GetYzmPath()
	
	if not cc.FileUtils:getInstance():isDirectoryExist(cacheDir) then
		cc.FileUtils:getInstance():createDirectory(cacheDir)
	end

	FileHelper.CheckDir(cacheDir, true)
	local fullFileName = cachePath
	local fHandle = io.open(fullFileName, "wb")
	if fHandle then
		fHandle:write(recvdata)
		fHandle:close()
	end
end 
