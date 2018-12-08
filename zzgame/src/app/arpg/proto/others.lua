-------------------------
-- 协议
-------------------------
module("proto",package.seeall)

function on_fail(recvdata)
	if not recvdata then return end
	if not recvdata.code then return end
	if recvdata.code == 429 then return end  --这时候弹“请第一时间绑定收款方式”的弹出框
	
	if setting.T_net_fail[recvdata.code] then
		utils.TellMe(setting.T_net_fail[recvdata.code])
	else
		if recvdata.msg and recvdata.msg ~= "" then
			utils.TellMe(recvdata.msg)
		end
	end 
end

function get_fail_msg(recvdata)
	if not recvdata or proto.is_success(recvdata) then return nil end
	return recvdata.msg
end

function is_success(recvdata)
	return recvdata ~= nil and recvdata.code == 200
end

function deal_spec_fail_code(recvdata)
	local errCode = recvdata and recvdata.code
	if not errCode then return end
	
	if errCode == 601 then
		logger.error("被踢出")
		--ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(false)
	--	ClsLoginMgr.GetInstance():Set_isNeedRegistYzm(false)
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.kicked)
		KE_SetTimeout(3, function() utils.TellMe("请重新登录") end)
	elseif errCode == 401 then
		logger.error("没有登录")
		--ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(false)
	--	ClsLoginMgr.GetInstance():Set_isNeedRegistYzm(false)
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.ready)
		KE_SetTimeout(3, function() utils.TellMe("请先登录") end)
	elseif errCode == 604 then
		logger.error("退出登录")
		--ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(false)
	--	ClsLoginMgr.GetInstance():Set_isNeedRegistYzm(false)
		UserDefaultData:Set_willquicklogon(false)
		ClsLoginMgr.GetInstance():SetCurState(const.LOGON_STATE.logout)
    elseif errCode == 425 then
        ClsLoginMgr.GetInstance():Set_isNeedLoginYzm(true)
	end
end
