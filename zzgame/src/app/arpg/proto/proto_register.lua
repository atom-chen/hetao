-------------------------
-- 协议注册器
-------------------------
local proto_register = {}

function proto_register:RegisterProtocal(filepath)
	local infolist = require(filepath)
	for _, info in pairs(infolist) do
		local ptoname = info.name
		local respFuncName = "on_"..ptoname
		local failFuncName = "fail_"..ptoname
		local errorFuncName = "error_"..ptoname
		g_AllProtocal[ptoname] = info
		g_AllRespFuncName[ptoname] = respFuncName
		g_AllFailFuncName[ptoname] = failFuncName
		g_AllErrorFuncName[ptoname] = errorFuncName
		g_EventMgr:RegisterEventType(respFuncName)
		g_EventMgr:RegisterEventType(failFuncName)
		g_EventMgr:RegisterEventType(errorFuncName)
		assert( proto[respFuncName], string.format("没有定义响应协议：%s",respFuncName) )
		proto[ptoname] = function(tParams, tUrlParams, unsafeCallback)
			HttpUtil:Request(ptoname, tParams, tUrlParams, unsafeCallback)
		end
	end
end

function proto_register:RegisterAllProtocal()
	logger.net("开始生成协议......")
	self:RegisterProtocal("app.arpg.proto.protocal_define.award")
	self:RegisterProtocal("app.arpg.proto.protocal_define.bet")
	self:RegisterProtocal("app.arpg.proto.protocal_define.daily_reward")
	self:RegisterProtocal("app.arpg.proto.protocal_define.goucai")
	self:RegisterProtocal("app.arpg.proto.protocal_define.grade")
	self:RegisterProtocal("app.arpg.proto.protocal_define.helpdoc")
	self:RegisterProtocal("app.arpg.proto.protocal_define.home")
	self:RegisterProtocal("app.arpg.proto.protocal_define.login")
	self:RegisterProtocal("app.arpg.proto.protocal_define.pay")
	self:RegisterProtocal("app.arpg.proto.protocal_define.user")
	self:RegisterProtocal("app.arpg.proto.protocal_define.agent")
	self:RegisterProtocal("app.arpg.proto.protocal_define.redbag")
	logger.net( "生成协议完成")
end

return proto_register
