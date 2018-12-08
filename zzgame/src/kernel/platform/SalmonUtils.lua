-------------------------------
-- 工具接口，具体实现请看对应文件夹
-------------------------------
SalmonUtils = {}

function SalmonUtils:getPhoneType()
	return ""
end

function SalmonUtils:openAnotherApp(packname, appname)
	print("当前平台不支持")
end

function SalmonUtils:fixUrl2utf8(url)
    return url
end

function SalmonUtils:getSafeAreaBottomHei()
    return 0
end

function SalmonUtils:getSafeAreaTopHei()
    return 0
end

function SalmonUtils:getKeyboardHei()
    return 0
end

function SalmonUtils:getAdjustHei()
	return 0
end

-- 设置音量大小
function SalmonUtils:setVolume(percent)
	print("当前平台不支持")
end

-- 设置亮度
function SalmonUtils:setBrightness(percent)
	print("当前平台不支持")
end

-- 获取音量大小
function SalmonUtils:getVolume()
	return 1.0
end

-- 获取当前亮度
function SalmonUtils:getBrightness()
	return 1.0
end

-- 保存相片到相册
function SalmonUtils:saveImageToPhotos(handler, captureName)
    print("当前平台不支持")
end

local pics = {
	"uistu/bg/bg_login.png",
	"uistu/bg/lucky_moeny_second.png",
	"uistu/bg/incarnate_no_money.png",
}

-- 打开图库选取一张图
function SalmonUtils:openGallery(handler)
	print("当前平台不支持")
	if handler then
		handler(pics[math.random(1,#pics)])
	end
end

-- 拍照
function SalmonUtils:captureImage(captureName, handler)
	print("当前平台不支持")
	if handler then
		handler(pics[math.random(1,#pics)])
	end
end

-- 获取缓存大小
function SalmonUtils:getTotalCacheSize()
	print("当前平台不支持")
	return "0.0KB"
end

-- 清除所有缓存
function SalmonUtils:clearAllCache()
	print("当前平台不支持")
end

-- 获取所在城市
function SalmonUtils:getCNBylocation(handler)
	print("当前平台不支持")
	return "未定位"
end

function SalmonUtils:isOpenFlashLight()
	return self.isFlashOn
end

-- 打开闪光灯
function SalmonUtils:openFlashLight()
	print("当前平台不支持")
end

--关闭闪光灯
function SalmonUtils:closeFlashLight()
	print("当前平台不支持")
end

-- 复制字符
function SalmonUtils:copy(content)
	print("当前平台不支持")
end

-- 黏贴
function SalmonUtils:paste()
	print("当前平台不支持")
	return ""
end

function SalmonUtils:getAllPhoneNums()
	print("当前平台不支持")
	return ""
end

function SalmonUtils:setUploadHandler(handler)
	print("当前平台不支持")
end

function SalmonUtils:upload(filename, key, token)
	print("当前平台不支持")
end

function SalmonUtils:uploadCancel()
	print("当前平台不支持")
end

function SalmonUtils:copyToWritablePath(dir)
	print("当前平台不支持")
end

--[[横竖屏幕切换
	 type: 1横 2 竖
]]
function SalmonUtils:setOrientation(type)
	print("当前平台不支持")
end

function SalmonUtils:resetGLView(t)
	-- local view = display:getOpenGLView()
	-- local view = cc.Director:getInstance():getOpenGLView()
	-- local frameSize = view:getFrameSize()

	-- local curFrameSize = frameSize

	-- -- 默认竖屏
	-- local width = 640
	-- local height = 1136
	-- local policy = cc.ResolutionPolicy.FIXED_WIDTH
	-- if frameSize.width > frameSize.height then
	-- 	curFrameSize = cc.size(frameSize.height, frameSize.width)
	-- end

	-- -- 如果是横屏
	-- if t == 1 then
	-- 	-- width = 1136
	-- 	-- height = 640
	-- 	-- policy = cc.ResolutionPolicy.FIXED_HEIGHT
	-- 	if frameSize.width < frameSize.height then
	-- 		curFrameSize = cc.size(frameSize.height, frameSize.width)
	-- 	end
	-- end
	-- print_r(curFrameSize, "cur frame size")
	-- view:setFrameSize(curFrameSize.width, curFrameSize.height)
	-- view:setDesignResolutionSize(width, height, policy)
end

--状态栏显示隐藏
function SalmonUtils:setStatusBarVisible(isShow)
	print("当前平台不支持")
end

--打开Gps设置界面
function SalmonUtils:openGpsSetting()
	print("当前平台不支持")
end


function SalmonUtils:setTransparentStatusBar()
	print("当前平台不支持")
end

function SalmonUtils:setOrientationEnable(b)
	print("当前平台不支持")
end

function SalmonUtils:getOrientationEnable()
	print("当前平台不支持")
	return true
end

function SalmonUtils:setScreenHandler(handler)
	print("当前平台不支持")
end

--[[
	截屏
	handler(success, outputFile)
]]
function SalmonUtils:snapshot(filename, handler)
	ScriptHandlerMgr:getInstance():removeObjectAllHandlers(utils.SnapshotUtils:getInstance():getHandlerContainer())
	ScriptHandlerMgr:getInstance():registerScriptHandler(
					utils.SnapshotUtils:getInstance():getHandlerContainer(), 
					handler, cc.Handler.EVENT_SNAPSHOT)
	utils.SnapshotUtils:getInstance():take(filename)
end

function SalmonUtils:qnUpload(filename, key, token, buket, handler)
	buket = buket or "liveshow"

	ScriptHandlerMgr:getInstance():removeObjectAllHandlers(
		utils.QiNiuUploadUtils:getInstance():getHandlerContainer());

	ScriptHandlerMgr:getInstance():registerScriptHandler(
	utils.QiNiuUploadUtils:getInstance():getHandlerContainer(), 
	handler, cc.Handler.EVENT_QINIU_UPLOAD)

	utils.QiNiuUploadUtils:getInstance():upload(filename, key, token, buket)
end

function SalmonUtils:getWindowRect()
	return 250
end

-- 设置网络状态监听回调
function SalmonUtils:setNetworkChangeEvent(handler)
	print("当前平台不支持")
end

function SalmonUtils:getConnectedType()
	print("当前平台不支持")
	return 1
end

-- 获取摄像头权限状态
function SalmonUtils:cameraAuthorization()
	return AVPermission.Authorized
end

function SalmonUtils:audioAuthorization()
	return AVPermission.Authorized
end

function SalmonUtils:cameraAuthCode()
	return AVPermission.Authorized
end

function SalmonUtils:audioAuthCode()
	return AVPermission.Authorized
end

function SalmonUtils:getStatusBarHeight()
	print("當前平台無效")
	return 54
end

function SalmonUtils:numberOfCameras()
	print("当前平台不支持")
	return 2
end

-- 设置是否保持屏幕常亮
function SalmonUtils:setIsKeepWake(isKeepWake)
	print("SalmonUtils:setIsKeepWake 当前平台不支持")
end

-- 获取定位权限
function SalmonUtils:getLocationAuth()
	return AVPermission.Authorized
end

function SalmonUtils:locationAuthorization()
	return AVPermission.Authorized
end

function SalmonUtils:isEmulator()
	return false
end

function SalmonUtils:getVersionName()
	-- print("当前平台不支持")
	-- return nil
	return "1.00.1"
end

function SalmonUtils:getInfoDataByKey(_key)
	return "testClient" -- 测试用,电脑获取的渠道ID为appStore
end

function SalmonUtils:getOpenUrlData()
  

end

function SalmonUtils:getDeviceIdentity()
	
end

function SalmonUtils:accountLoginStatistics( uid )
	
end

function SalmonUtils:accountLogoutStatistics(  )
	
end

--获取资源版本
function SalmonUtils:getResVersion()

end

function SalmonUtils:getDeviceData()
	-- body
end

function SalmonUtils:getStatisticsDeviceData()
	-- body
end

function SalmonUtils:preLoginStatisticReq(actType, page, Locate)
	-- body
end

function SalmonUtils:getChannelId( )
	-- body
	return "imay"
end

function  SalmonUtils:getNotifyCategoryType()
	-- body
end

function SalmonUtils:setStatusBarEventHandler(handler)
	print("状态栏点击事件回调未实现")
end

function SalmonUtils:getBundleId()
	-- body
end

function SalmonUtils:umengAnalyticsEvent(eventId)
end

function SalmonUtils:appTrackRegister(uid)
  
end

function SalmonUtils:onProfileSignIn(Provider, UID)
end

function SalmonUtils:onProfileSignOff()
end
