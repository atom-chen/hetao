--[[
------------------------------------------------------------------

                            _ooOoo_  
                           o8888888o  
                           88" . "88  
                           (| -_- |)  
                            O\ = /O  
                        ____/`---'\____  
                      .   ' \\| |// `.  
                       / \\||| : |||// \  
                     / _||||| -:- |||||- \  
                       | | \\\ - /// | |  
                     | \_| ''\---/'' | |  
                      \ .-\__ `-` ___/-. /  
                   ___`. .' /--.--\ `. . __  
                ."" '< `.___\_<|>_/___.' >'"".  
               | | : `- \`.;`\ _ /`;.`/ - ` : | |  
                 \ \ `-. \_ __\ /__ _/ .-` / /  
         ======`-.____`-.___\_____/___.-`____.-'======  
                            '=---='  
                 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                   
------------------------------------------------------------------
]]--

function __G__TRACKBACK__(errorMessage)
	print("----------------------------------------")
	print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
	print(debug.traceback("", 2))
	print("----------------------------------------")
	local target = cc.Application:getInstance():getTargetPlatform()
	if target == cc.PLATFORM_OS_ANDROID or target == cc.PLATFORM_OS_IPHONE or target == cc.PLATFORM_OS_IPAD then
		buglyReportLuaException(tostring(errorMessage), debug.traceback("", 2))
	end
end

function unquire(filepath)
	if package.loaded[filepath] ~= nil then
		print("卸载文件：", filepath)
	else
		print("卸载不存在的文件：", filepath)
	end 
	package.loaded[filepath] = nil
end


local function main()
	print("main......")
	collectgarbage("setpause", 100) 
	collectgarbage("setstepmul", 5000)
	math.randomseed(os.time()) 
	math.random() 
	math.random() 
	math.random()
	
	cc.Director:getInstance():setClearColor({ r = 238, g = 238, b = 238, a = 255 })
	cc.FileUtils:getInstance():setPopupNotify(false)
	local updateDir = cc.UserDefault:getInstance():getStringForKey("update_dir", "")
	if updateDir ~= "" then
		cc.FileUtils:getInstance():addSearchPath(updateDir.."res/", true)
	end
	cc.FileUtils:getInstance():addSearchPath("res")
	cc.FileUtils:getInstance():addSearchPath("src")
	
	
	require("laucher.config")
	require("laucher.logger")
	logger.EnablePrint(false)
	require("cocos.init")
	logger.EnablePrint(IS_DEBUG_MODE)
	print("本地缓存路径",GAME_CONFIG.LOCAL_DIR)
	
	local function finishCallback(tbLoadChunkZips)
		--- 热更完毕
		--- 1. 卸载 laucher和cocos，实现laucher和cocos的自我更新
		unquire("laucher.config")
		unquire("laucher.logger")
		unquire("laucher.HotUpdate")
		unquire("laucher.MsgBox")
		unquire("laucher.override_traceback")
-- 		unquire(cocos)
		
		--- 2. 重设搜索路径
		cc.FileUtils:getInstance():setPopupNotify(false)
		local updateDir = cc.UserDefault:getInstance():getStringForKey("update_dir", "")
		if updateDir ~= "" then
			cc.FileUtils:getInstance():addSearchPath(updateDir.."res/", true)
		end
		cc.FileUtils:getInstance():addSearchPath("res")
		cc.FileUtils:getInstance():addSearchPath("src")
		
		--- 3. 重新加载模块包
		local tbZip = { "res/laucher.zip","res/cocos.zip","res/lib.zip","res/kernel.zip","res/app.zip" }
		if tbLoadChunkZips then
			tbZip = tbLoadChunkZips
		end
		for i = 1,#tbZip do
			if cc.FileUtils:getInstance():isFileExist(tbZip[i]) then
				cc.LuaLoadChunksFromZIP(tbZip[i])
			end
		end
        
		require("laucher.config")
		require("laucher.logger")
		logger.EnablePrint(false)
		require("cocos.init")
		logger.EnablePrint(IS_DEBUG_MODE)
		require("laucher.override_traceback")
		
		if device.platform == "windows" then
			require("laucher.auto_init")
		end 
		
		--
		require("app.CApp")
		ClsApp.GetInstance():Run()
	end
	
	local HotUpdate = require("laucher.HotUpdate")
	HotUpdate:checkUpdate(finishCallback)
end

xpcall(main, __G__TRACKBACK__)
