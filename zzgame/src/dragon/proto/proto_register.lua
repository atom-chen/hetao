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
	logger.net("开始生成长龙协议......")
	self:RegisterProtocal("dragon.proto.protocal_define.dragon")
    logger.net( "生成长龙协议完成")
end

return proto_register
