-------------------------
-- 调试
-------------------------

function SendDebugMsg(errTip, errStr)
	local target = cc.Application:getInstance():getTargetPlatform()
    if target == cc.PLATFORM_OS_ANDROID or target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
        buglyReportLuaException(tostring(errTip), errStr)
    end
end


function DumpDebugInfo()
	print("++++++++++++++++++++++++++++++++++++++++++\n")
	
	print("*************** 纹理缓存 ***************")
	print( cc.Director:getInstance():getTextureCache():getCachedTextureInfo() )
	
	print("*************** LUA内存占用 ***************")
	print( string.format("%fM", collectgarbage("count")/1000) )
	
	print("*************** 类定义信息 ***************")
	print("定义的类数量：", table.size(GetAllClass()))
	
	print("*************** 定时器 *****************")
	ClsTimerManager.GetInstance():DumpDebugInfo()
	
	print("*************** UI ***************")
	ClsUIManager.GetInstance():DumpDebugInfo()
	
--	print("*************** 全局事件中心 ***************")
--	g_EventMgr:DumpDebugInfo()
	
	print("*************** 保存TextureMerge ***************")
	xianyou.TextureMerge:getInstance():saveToFile(GAME_CONFIG.LOCAL_DIR .. "/merge.png")
	
	print("++++++++++++++++++++++++++++++++++++++++++\n")
end
