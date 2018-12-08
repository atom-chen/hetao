-------------------------
-- 检查Lua内存泄露
-------------------------
-- 将要检查泄露的对象加入该表
mem_leak_helper = {}
setmetatable(mem_leak_helper, {__mode = "kv"})

function CheckMemoryLeak()
	if not GAME_CONFIG.VV_ENABLE_MEMLEAK_CHECK then return end
	collectgarbage("collect")
	collectgarbage("collect")
	print("-----------Lua内存泄露检查开始-----------")
	
	local traceinfo = {}
	for obj, dbgstr in pairs(mem_leak_helper) do
		traceinfo[#traceinfo+1] = dbgstr
	end
	logger.dump(traceinfo)
	
	print("-----------Lua内存泄露检查结束-----------")
	collectgarbage("collect")
	collectgarbage("collect")
end

function AddMemoryMonitor(obj)
	if GAME_CONFIG.VV_ENABLE_MEMLEAK_CHECK then
		mem_leak_helper[obj] = debug.traceback()
	end 
end
