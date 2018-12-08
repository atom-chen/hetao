-------------------------
-- 热更
-------------------------
local MsgBox = require("laucher.MsgBox")
local cjson = require("cjson")
local plattarget = cc.Application:getInstance():getTargetPlatform()
local luaj = {}
local luaoc = {}
local FAIL_TRY_COUNT = 10

if plattarget == cc.PLATFORM_OS_ANDROID then
	local callJavaStaticMethod = LuaJavaBridge.callStaticMethod
	local function checkArguments(args, sig)
		if type(args) ~= "table" then args = { } end
		if sig then return args, sig end

		sig = { "(" }
		for i, v in ipairs(args) do
			local t = type(v)
			if t == "number" then
				sig[#sig + 1] = "F"
			elseif t == "boolean" then
				sig[#sig + 1] = "Z"
			elseif t == "function" then
				sig[#sig + 1] = "I"
			else
				sig[#sig + 1] = "Ljava/lang/String;"
			end
		end
		sig[#sig + 1] = ")V"

		return args, table.concat(sig)
	end

	function luaj.callStaticMethod(className, methodName, args, sig)
		local args, sig = checkArguments(args, sig)
		return callJavaStaticMethod(className, methodName, args, sig)
	end
elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
	local callStaticMethod = LuaObjcBridge.callStaticMethod
	function luaoc.callStaticMethod(className, methodName, args)
		local ok, ret = callStaticMethod(className, methodName, args)
		if not ok then
			local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
			className, methodName, tostring(args), tostring(ret))
			if ret == -1 then
				print(msg .. "INVALID PARAMETERS")
			elseif ret == -2 then
				print(msg .. "CLASS NOT FOUND")
			elseif ret == -3 then
				print(msg .. "METHOD NOT FOUND")
			elseif ret == -4 then
				print(msg .. "EXCEPTION OCCURRED")
			elseif ret == -5 then
				print(msg .. "INVALID METHOD SIGNATURE")
			else
				print(msg .. "UNKNOWN")
			end
		end
		return ok, ret
	end
end

local function json_decode(text)
	local status, result = pcall(cjson.decode, text)
	if status then return result end
end

local function json_encode(var)
	local status, result = pcall(cjson.encode, var)
	if status then return result end
end

local function string_split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)
	if (delimiter == '') then return false end
	local pos, arr = 0, { }
	-- for each divider found
	for st, sp in function() return string.find(input, delimiter, pos, true) end do
		table.insert(arr, string.sub(input, pos, st - 1))
		pos = sp + 1
	end
	table.insert(arr, string.sub(input, pos))
	return arr
end

local function get_dir(path)
	for i = #path, 1, -1 do
		print(string.sub(path, i, i))
		if string.sub(path, i, i) == "/" then
			return string.sub(path, 1, i)
		end
	end
	return ""
end

local function onPageEvent(id, name)
	local tbParam = { name = name }
	if plattarget == cc.PLATFORM_OS_ANDROID then
		tbParam = json_encode(tbParam)
		tbParam = { tbParam }
		ok, ret = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "onPageEvent", tbParam, "(Ljava/lang/String;)V")
	elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
		ok, ret = luaoc.callStaticMethod("AppController", "onRegister", tbParam)
	else
		tbParam = json_encode(tbParam)
		tbParam = { tbParam }
	end
end

local function getChannel()
	if plattarget == cc.PLATFORM_OS_ANDROID then
		local ok, ret = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "getChannel", { }, "()Ljava/lang/String;")
		if ok then
			return ret
		else
			return ""
		end
	elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
		local ok, ret = luaoc.callStaticMethod("AppController", "getChannel", { })
		if ok then
			return ret
		else
			return ""
		end
	end
end

-- 迭代root上所有命名节点到tbl
local function getNamedNodes(root, tbl)
	tbl = tbl or root
	local function getNode(parent)
		if (not parent) or(not parent.getChildren) then return end
		local children = parent:getChildren()
		for _, v in pairs(children) do
			tbl[v:getName()] = v
			getNode(v)
		end
	end
	getNode(root)
end

-- call by engine
function updateDownloadGame(percent)
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	local event = cc.EventCustom:new("updateDownloadGame")
	event._usedata = percent
	eventDispatcher:dispatchEvent(event)
end

-- call by engine 
local function isNetworkConnected()
    if plattarget == cc.PLATFORM_OS_ANDROID then
        local ok, ret = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "isNetworkConnected", { }, "()Z")
        return ret
    elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
        local ok, ret = luaoc.callStaticMethod("AppController", "isNetworkConnected", { })
        return ret == 1 and true or false
    end
    return true
end

local g_cur_scene = false
local function CheckNetConnect(curScene)
	local bConnected = isNetworkConnected()
	print("检查网络连接",bConnected)
	curScene = curScene or cc.Director:getInstance():getRunningScene()
	if not curScene then curScene = g_cur_scene end
	if curScene and not tolua.isnull(curScene) then
		if not bConnected then
			if not curScene._msgbox_net then
				curScene._msgbox_net = MsgBox:show(curScene, 11, "", "网络连接异常，请检查网络状况", nil, nil, nil, 2)
			end
		else
			if curScene._msgbox_net and not tolua.isnull(curScene._msgbox_net) then
				curScene._msgbox_net:removeFromParent()
				curScene._msgbox_net = nil
			end
		end
	else 
		print("-----------没场景")
	end
end
function networkStateChange(sState)
	local bConnected = isNetworkConnected()
	CheckNetConnect()
	--
	if not PlatformHelper or not PlatformHelper.isNetworkConnected then return end
	if ClsUIManager then
		if not bConnected then
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_NET_STATE", "", "网络连接异常，请检查网络状况", nil, nil, nil, 1)
		else
			ClsUIManager.GetInstance():CloseConfirmDlg("CFM_NET_STATE")
		end
	end
	if g_EventMgr then 
		g_EventMgr:FireEvent("NET_STATE_CHANGE", bConnected)
	end
end

-- call by engine 
function batteryChange(sPercent)
	
end

function getPhoneType()
	if plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
        local ok,ret  = luaoc.callStaticMethod("SalmonUtils","getPhoneType",{})
        if ok then
        	return ret 
        else
        	return ""
        end
    end
end

function getImgByPhoneType()
	return nil
	--[[
	if not cc.Sprite:create("launcher/first_page2.png") then
		return nil
	end
	local respath = "launcher/first_page2.png"
	local ptype = getPhoneType() or ""
	if string.find(ptype, "iPhone X") then
		respath = "launcher/first_page2.png"
	end
	return respath
	]]
end

--------------------------------------------------------------------------------------------

local UpdateState = {}
UpdateState.CHECK_UPDATE = 0	--检查更新
UpdateState.UPDATING = 1		--热更
UpdateState.DOWNLOADING = 2		--下载引擎包
UpdateState.LOADINGRES = 3		--解压和加载资源

local UpdateScene = {}

function UpdateScene:showDebugStr(str)
	if IS_DEBUG_MODE and str then
		print(str)
		self._dbgStrList = self._dbgStrList or {}
		table.insert(self._dbgStrList, str)
		
		if self.lblDbg and self.dbgView then 
			self.lblDbg:setString(table.concat(self._dbgStrList, "\n")) 
			self.dbgView:setInnerContainerSize(self.lblDbg:getContentSize())
			self.lblDbg:setPosition(0, self.dbgView:getInnerContainerSize().height)
		end
	end
end

function UpdateScene:initView()
	-- 创建场景
	local sharedDirector = cc.Director:getInstance()
	local theGLView = sharedDirector:getOpenGLView()
	if nil == theGLView then
		theGLView = cc.GLView:create("KuEngine")
		sharedDirector:setOpenGLView(theGLView)
	end

	self._curScene = cc.Scene:create()
	if sharedDirector:getRunningScene() then
		sharedDirector:replaceScene(self._curScene)
	else
		sharedDirector:runWithScene(self._curScene)
	end

	-- 创建UI
	local rootNode = cc.CSLoader:createNode("launcher/HotUpdateUI.csb")
	self._curScene:addChild(rootNode)
	getNamedNodes(rootNode, self)
--	rootNode:setContentSize(GAME_CONFIG.SCREEN_W, GAME_CONFIG.SCREEN_H)
	local firstpath = getImgByPhoneType()
	if firstpath and firstpath ~= "" then
		self.ImgFirstPage:loadTexture( firstpath )
	end
	self.ImgFirstPage:setContentSize(GAME_CONFIG.SCREEN_W, GAME_CONFIG.SCREEN_H)
	self.ImgFirstPage:setScale(GAME_CONFIG.DESIGN_W/GAME_CONFIG.SCREEN_W)
	
	g_cur_scene = self._curScene
	
	local yOffset = CUR_SITE_CFG.Y_OFFSET or 0
	self.progressBarBg:setPositionY(215+yOffset)
	self.progressBar:setPositionY(216+yOffset)
	self.updateTip:setPositionY(193+yOffset)
	
	-- 调试界面
	if IS_DEBUG_MODE then
		local dbgView = ccui.ScrollView:create()
		dbgView:setDirection(ccui.ScrollViewDir.vertical)
		dbgView:setBounceEnabled(true)
		dbgView:setBackGroundColorType(1)
		dbgView:setBackGroundColor({ r=111, g=111, b=111 })
		dbgView:setContentSize({ width = 720, height = 600 })
		dbgView:setPosition(0,300)
		rootNode:addChild(dbgView,99)
		
		local lblDbg = cc.Label:create()
		lblDbg:setSystemFontSize(24)
		lblDbg:setTextColor({ r = 0, g = 0, b = 0 })
		lblDbg:setLineBreakWithoutSpace(true)
		lblDbg:setMaxLineWidth(720)
		lblDbg:setDimensions(720, 0)
		lblDbg:setAnchorPoint(cc.p(0,1))
		lblDbg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
		dbgView:addChild(lblDbg)
		
		self.lblDbg = lblDbg
		self.dbgView = dbgView
	end
end

function UpdateScene:checkUpdate(callback)
	if IS_DEBUG_MODE then self:showDebugStr("开始热更 ......") end
	assert(type(callback) == "function")
	
	self._callback = callback
	
	self:initView()
	CheckNetConnect(self._curScene)
	
	onPageEvent(0, "进入游戏启动页_1030")

	self:updatePercent(UpdateState.CHECK_UPDATE, 0)

	--
	local writablepath = cc.FileUtils:getInstance():getWritablePath()
	self._storagepath = writablepath .. "hotupdate/"

	local versionFile = cc.FileUtils:getInstance():fullPathForFilename("version.manifest")
	if IS_DEBUG_MODE then self:showDebugStr( string.format("storagepath: %s", self._storagepath) ) end
	if IS_DEBUG_MODE then self:showDebugStr( string.format("versionFile: %s", versionFile) ) end
	if not cc.FileUtils:getInstance():isFileExist(versionFile) then
		if IS_DEBUG_MODE then self:showDebugStr("本地版本文件不存在") end
		self:updatePercent(UpdateState.CHECK_UPDATE, 100);
		self:updateFinish(false, "本地版本文件不存在")
		return
	end
	
	local versionJson = cc.FileUtils:getInstance():getStringFromFile(versionFile)
	local tbLocalVersionManifest = json_decode(versionJson)
	if not tbLocalVersionManifest then
		if IS_DEBUG_MODE then self:showDebugStr("加载本地版本文件失败") end
		self:updatePercent(UpdateState.CHECK_UPDATE, 100);
		self:updateFinish(false, "加载本地版本文件失败")
		return
	end

	self.updateFailedCount = 0
	self.errorUpdatingCount = 0
	self.errorDecompressCount = 0

	self:updatePercent(UpdateState.CHECK_UPDATE, 10)
	local remoteVersionUrl = tbLocalVersionManifest["remoteVersionUrl"]
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("localVersion: %s", tbLocalVersionManifest["version"]) ) end
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("packageUrl: %s", tbLocalVersionManifest["packageUrl"]) ) end
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("manifestFileUrl: %s", tbLocalVersionManifest["remoteManifestUrl"]) ) end
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("remoteVersionUrl: %s", tbLocalVersionManifest["remoteVersionUrl"]) ) end
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("remotePackageUrl: %s", tbLocalVersionManifest["remotePackageUrl"]) ) end
--	if IS_DEBUG_MODE then self:showDebugStr( string.format("hotupdateDir: %s", self._storagepath) )

	local xhr = cc.XMLHttpRequest:new()
	xhr.timeout = 10
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", remoteVersionUrl)
	local function onReadyStateChange()
--		if IS_DEBUG_MODE then self:showDebugStr(string.format("onReadyStateChange readyState == %d,status == %d", xhr.readyState, xhr.status)) end
		if xhr.readyState == 4 and(xhr.status >= 200 and xhr.status < 207) then
			if xhr.status ~= 200 then
				if IS_DEBUG_MODE then self:showDebugStr( string.format("获取远程版本失败: %s", remoteVersionUrl) ) end
				self:updatePercent(UpdateState.CHECK_UPDATE, 100)
				self:updateFinish(false, "获取远程版本失败")
			else
				local tbVersionManifest = json_decode(xhr.response)
				if tbVersionManifest and tbVersionManifest.version then
					local isForceUpdate = tbVersionManifest.isForceUpdate
					local remotePackageUrl = tbVersionManifest.remotePackageUrl
					local remoteVersion = tbVersionManifest.version
					local localVersion = tbLocalVersionManifest.version
					local tbRemote = string_split(remoteVersion, ".")
					local tbLocal = string_split(localVersion, ".")
					
					if #tbRemote == 3 and #tbLocal == 3 then
						local iRemote1 = tonumber(tbRemote[1])
						local iRemote2 = tonumber(tbRemote[2])
						local iRemote3 = tonumber(tbRemote[3])
						local iLocal1 = tonumber(tbLocal[1])
						local iLocal2 = tonumber(tbLocal[2])
						local iLocal3 = tonumber(tbLocal[3])
					
						if iRemote1 == iLocal1 and iRemote2 == iLocal2 then
							-- 检查热更
							if iRemote3 > iLocal3 then
--								if IS_DEBUG_MODE then self:showDebugStr(string.format("需要进行热更: %s --> %s", localVersion, remoteVersion)) end
								self:beginUpdate()
							else
--								if IS_DEBUG_MODE then self:showDebugStr(string.format("不需要进行热更: %s --> %s", localVersion, remoteVersion)) end
								self:updatePercent(UpdateState.CHECK_UPDATE, 100)
								self:updateFinish(true, "不需要进行热更")
							end
						else
							-- 检查引擎
--							if IS_DEBUG_MODE then self:showDebugStr(string.format("检查引擎更新: %s --> %s", localVersion, remoteVersion)) end
							if iRemote1 < iLocal1 then
								self:updatePercent(UpdateState.CHECK_UPDATE, 100)
								self:updateFinish(true, "已经是最新版本")
								return 
							elseif iRemote1 == iLocal1 then
								if iRemote2 < iLocal2 then
									self:updatePercent(UpdateState.CHECK_UPDATE, 100)
									self:updateFinish(true, "已经是最新版本")
									return
								end
							end
							if not remotePackageUrl or remotePackageUrl == "" then
								self:updatePercent(UpdateState.CHECK_UPDATE, 100)
								self:updateFinish(true, "已经是最新版本")
								return 
							end
							self:downEngine(remotePackageUrl, isForceUpdate)
						end
					else
--						if IS_DEBUG_MODE then self:showDebugStr(string.format("版本格式错误,终止热更: %s --> %s", localVersion, remoteVersion)) end
						self:updatePercent(UpdateState.CHECK_UPDATE, 100)
						self:updateFinish(false, "版本格式错误,终止热更")
					end
				else
--					if IS_DEBUG_MODE then self:showDebugStr(string.format("不存在版本号,终止热更: %s --> %s", localVersion, remoteVersion)) end
					self:updatePercent(UpdateState.CHECK_UPDATE, 100)
					self:updateFinish(false, "不存在版本号,终止热更")
				end
			end
		else
			if IS_DEBUG_MODE then self:showDebugStr( string.format("获取远程版本失败: %s", url) ) end
			self:updatePercent(UpdateState.CHECK_UPDATE, 100)
			self:updateFinish(false, "获取远程版本失败")
		end
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

function UpdateScene:downEngine(remotePackageUrl, isForceUpdate)
	-- 监听apk下载进度
	local listener = cc.EventListenerCustom:create("updateDownloadGame", function(event)
		local percent = event._usedata
		self:updatePercent(UpdateState.DOWNLOADING, percent)
	end )
	local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.progressBarBg)
	
	if isForceUpdate then
		MsgBox:show(self._curScene, 10, "发现新版本", "需要下载更新才能继续游戏", function(flag)
			if flag == 1 then
				if plattarget == cc.PLATFORM_OS_ANDROID then
					local ok, ret = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "downloadApk", {remotePackageUrl}, "(Ljava/lang/String;)V")
					self:updatePercent(UpdateState.DOWNLOADING, 0)
				elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
					cc.Application:getInstance():openURL(remotePackageUrl)
					self:updatePercent(UpdateState.DOWNLOADING, 50)
				else
					cc.Application:getInstance():openURL(remotePackageUrl)
					self:updatePercent(UpdateState.DOWNLOADING, 50)
				end
			else
				cc.Director:getInstance():endToLua()
    			if device.platform ~= "android" then
        			os.exit(0)
    			end
			end
		end)
	else
		MsgBox:show(self._curScene, 10, "发现新版本", "是否下载更新", function(flag)
			if flag == 1 then
				if plattarget == cc.PLATFORM_OS_ANDROID then
					local ok, ret = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "downloadApk", {remotePackageUrl}, "(Ljava/lang/String;)V")
					self:updatePercent(UpdateState.DOWNLOADING, 0)
				elseif plattarget == cc.PLATFORM_OS_IPHONE or plattarget == cc.PLATFORM_OS_IPAD then
					cc.Application:getInstance():openURL(remotePackageUrl)
					self:updatePercent(UpdateState.DOWNLOADING, 50)
				else
					self:updatePercent(UpdateState.DOWNLOADING, 100)
					self:updateFinish(true, "忽略引擎更新")
				end 
			else
				self:updatePercent(UpdateState.CHECK_UPDATE, 100)
				self:updateFinish(true, "忽略引擎更新")
			end
		end)
	end
end

function UpdateScene:beginUpdate()
	self._am = cc.AssetsManagerEx:create("project.manifest", self._storagepath)
	self._am:retain()
	
	if not self._am:getLocalManifest():isLoaded() then
		if IS_DEBUG_MODE then self:showDebugStr("加载本地清单文件失败") end
		self:updatePercent(UpdateState.CHECK_UPDATE, 100)
		self:updateFinish(false, "加载本地清单文件失败")
		return
	end
								
	self:updatePercent(UpdateState.UPDATING, 0)
	local listener = cc.EventListenerAssetsManagerEx:create(self._am, function(event)
		self:onUpdateEvent(event)
	end )
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
	self._am:update()
end

function UpdateScene:updatePercent(state, iCurPercent)
	if self.progressBar then self.progressBar:setPercent(iCurPercent) end
	if state == UpdateState.CHECK_UPDATE then
		self.updateTip:setString("检查更新中...")
	elseif state == UpdateState.UPDATING then
		self.updateTip:setString(string.format("更新资源中.....%d%%", iCurPercent))
	elseif state == UpdateState.DOWNLOADING then
		self.updateTip:setString(string.format("下载新版本中.....%d%%", iCurPercent))
	elseif state == UpdateState.LOADINGRES then
		self.updateTip:setString(string.format("加载资源中.....%d%%", iCurPercent))
	end
end

function UpdateScene:updateFinish(bSucc, strErrReason)
	g_cur_scene = nil 
	if IS_DEBUG_MODE then self:showDebugStr("热更完毕。。。。。。。") end
	if self._am then
		self._am:release()
		self._am = nil
	end
	
	local listener = cc.EventListenerCustom:create("update_scene_loading_res", function(event)
        self:updatePercent(UpdateState.LOADINGRES, event._usedata)
    end )
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.progressBarBg)
	
	local delayTm = 0.06
--	if IS_DEBUG_MODE then delayTm = 5 end
	local handle
	handle = cc.Director:getInstance():getScheduler():scheduleScriptFunc( function()
		cc.Director:getInstance():getScheduler():unscheduleScriptEntry(handle)
		if cc.FileUtils:getInstance():isFileExist("res/version.manifest") then
			local json = cc.FileUtils:getInstance():getStringFromFile("res/version.manifest")
			local tbVersion = json_decode(json)
			if tbVersion then
				self._callback(tbVersion.loadChunkZips)
			else
				self._callback(nil)
			end
		else
			self._callback(nil)
		end
	end , delayTm, false)
end

function UpdateScene:onUpdateEvent(event)
	local eventCode = event:getEventCode()
	local assetId = event:getAssetId()
	local percent = event:getPercent()
	local percentByFile = event:getPercentByFile()
	local message = event:getMessage()
--	if IS_DEBUG_MODE then self:showDebugStr(string.format("游戏更新(%d): assetId->%s, percent->%d, percentByFile->%s, message->%s", eventCode, assetId, percent, percentByFile, message)) end
	
	if eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE then
		if IS_DEBUG_MODE then self:showDebugStr("已经是服务器最新版本 ALREADY_UP_TO_DATE") end
		self:updatePercent(UpdateState.UPDATING, 100)
		self:updateFinish(true, "已经是最新版本")
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
		if IS_DEBUG_MODE then self:showDebugStr( string.format("发现新版本 NEW_VERSION_FOUND %s", self._am:getRemoteManifest():getVersion()) ) end
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
		if event:getAssetId() == cc.AssetsManagerExStatic.VERSION_ID then
--			if IS_DEBUG_MODE then self:showDebugStr( string.format("更新版本文件: %s",self._am:getRemoteManifest():getVersion()) ) end
		elseif event:getAssetId() == cc.AssetsManagerExStatic.MANIFEST_ID then
--			if IS_DEBUG_MODE then self:showDebugStr( "更新清单文件" ) end
		else
--			if IS_DEBUG_MODE then self:showDebugStr( string.format("更新资源文件: %s", event:getAssetId()) ) end
			self:updatePercent(UpdateState.UPDATING, percentByFile)
		end
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
--		if IS_DEBUG_MODE then self:showDebugStr(string.format("%s ASSET_UPDATED", assetId)) end
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
		if IS_DEBUG_MODE then self:showDebugStr("更新到服务器最新版本 UPDATE_FINISHED") end
		cc.UserDefault:getInstance():setStringForKey("update_dir", self._storagepath)
		self:updatePercent(UpdateState.UPDATING, 100)
		self:updateFinish(true, "更新成功")
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
		if IS_DEBUG_MODE then self:showDebugStr( string.format("更新失败 UPDATE_FAILED %s", self.updateFailedCount) ) end
		if self.updateFailedCount == FAIL_TRY_COUNT then
			-- 如果有的文件更新失败,重试更新FAIL_TRY_COUNT次
			MsgBox:show(self._curScene, 10, "更新失败", "请确保网络顺畅和存储空间充足后重试", function(index)
				self.updateFailedCount = 0
				self.errorUpdatingCount = 0
				self.errorDecompressCount = 0
				self:updatePercent(UpdateState.UPDATING, 0)
                self:updateFinish(false, "更新失败：下载失败")
			end)
		else
			self.updateFailedCount = self.updateFailedCount + 1
			self:updatePercent(UpdateState.UPDATING, 0)
			self._am:downloadFailedAssets()
		end
		
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
		if IS_DEBUG_MODE then self:showDebugStr("不存在本地文件清单 ERROR_NO_LOCAL_MANIFEST") end
		self:updatePercent(UpdateState.UPDATING, 100)
		self:updateFinish(false, "不存在本地文件清单")
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST then
		if IS_DEBUG_MODE then self:showDebugStr("下载远程文件清单失败 ERROR_DOWNLOAD_MANIFEST") end
		self:updatePercent(UpdateState.UPDATING, 100)
		self:updateFinish(false, "下载远程文件清单失败")
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
		if IS_DEBUG_MODE then self:showDebugStr("解析远程文件清单失败 ERROR_PARSE_MANIFEST") end
		self:updatePercent(UpdateState.UPDATING, 100)
		self:updateFinish(false, "解析远程文件清单失败")
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
		self.errorUpdatingCount = self.errorUpdatingCount + 1
		if IS_DEBUG_MODE then self:showDebugStr( string.format("下载该文件失败 ERROR_UPDATING %s", self.errorUpdatingCount) ) end
	elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
		if IS_DEBUG_MODE then self:showDebugStr("解压文件失败 ERROR_DECOMPRESS") end
		if self.errorDecompressCount == FAIL_TRY_COUNT then
			self._am:release()
			self._am = nil 
			MsgBox:show(self._curScene, 10, "解压失败", "请确保网络顺畅和存储空间充足后重试", function(index)
				self._am = cc.AssetsManagerEx:create("project.manifest", self._storagepath)
				self._am:retain()
				self.updateFailedCount = 0
				self.errorUpdatingCount = 0
				self.errorDecompressCount = 0
				self:updatePercent(UpdateState.UPDATING, 0)
				local listener = cc.EventListenerAssetsManagerEx:create(self._am, function(event)
					self:onUpdateEvent(event)
				end )
				cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
				self._am:update()
			end)
		else
			self.errorDecompressCount = self.errorDecompressCount + 1
		end
	end
end

return UpdateScene
