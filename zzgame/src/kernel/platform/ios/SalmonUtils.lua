if device.platform ~= "ios" then return end

local luaoc = require("cocos.cocos2d.luaoc")
local className = "SalmonUtils"
local osinfoClassName = "OSInfoUtils"

function enterRoomFromPushNotify(roomId, url)
    
end

function aliAuthResultCode(auth_code)
    
end

function callNotifyFuncByCategory( category )
   	
end

-- 显示状态栏
local function showStatusBar()
    KE_SetTimeout(5, function() SalmonUtils:setStatusBarVisible(true) end)
end

SalmonUtils = {}

function SalmonUtils:getPhoneType()
	local ok,ret  = luaoc.callStaticMethod(className,"getPhoneType",{})
	if not ok then
		print("luaj error:", ret)
		return ""
	else
		-- print("The ret is:", ret)
		return ret 
	end
end

function SalmonUtils:openWeixin()
	local ok,ret  = luaoc.callStaticMethod(className,"openWeixin",{})
	if not ok then
		print("luaj error:", ret)
	else
		-- print("The ret is:", ret)
	end
end

function SalmonUtils:getSafeAreaBottomHei()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod("AppController","getSafeAreaBottomHei",{})
    if not ok then
        print("luaoc error:", ok)
        return 0
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:getSafeAreaTopHei()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod("AppController","getSafeAreaTopHei",{})
    if not ok then
        print("luaoc error:", ok)
        return 0
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:getKeyboardHei()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod("AppController","getKeyboardHei",{})
    if not ok then
        print("luaoc error:", ok)
        return 0
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:getAdjustHei()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod("AppController","getAdjustHei",{})
    if not ok then
        print("luaoc error:", ok)
        return 0
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:fixUrl2utf8(url)
	if not url or url == "" then return "" end
    local args = { urlStr = url }
    local ok,ret  = luaoc.callStaticMethod(className,"fixUrl2utf8",args)
    if not ok then
        return url
    else
    	if not ret or type(ret) ~= "string" then return url end
    	local s1 = string.find(ret or "", "http")
    	if not s1 then return url end
        return ret
    end
end

function SalmonUtils:setVolume(_percent)
	-- print("警告：SalmonUtils:setVolume IOS接口未 实现")
	local args = { percent = _percent }
    local ok,ret  = luaoc.callStaticMethod(className,"setVolume",args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
end

function SalmonUtils:getVolume()
    -- print("警告：SalmonUtils:setVolume IOS接口未实现")
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getVolume")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
end


function SalmonUtils:setBrightness(_percent)
	-- print("警告：SalmonUtils:setBrightness IOS接口未实现")
	_percent = tonumber(_percent)
	local args = { percent = _percent }
    local ok,ret  = luaoc.callStaticMethod(className,"setBrightness",args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
end

function SalmonUtils:getBrightness()
    -- print("警告：SalmonUtils:setBrightness IOS接口未实现")
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getBrightness")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
end

-- 保存相片到相册
function SalmonUtils:saveImageToPhotos(handler, captureName)
    local args = {scriptHandler = handler, imageName = captureName}
    local ok,ret  = luaoc.callStaticMethod(className,"saveImageToPhotos",args)
    if not ok then
        print("luaoc error:", ret)
    else
    end
end

-- 打开图库选取一张图
function SalmonUtils:openGallery(handler, captureName)
    -- print("openGallery")
    if not captureName then
        captureName = "/image.png"
    end
    captureName = "/"..captureName

    local function callback(path)
    --    showStatusBar()
        if handler then
            handler(path)
        end
    end

    --print("警告：SalmonUtils:openGallery IOS接口未实现"..captureName)
    local args = {scriptHandler = callback, imageName = captureName}
    local ok,ret  = luaoc.callStaticMethod(className,"openGallery",args)
    if not ok then
        print("luaoc error:", ret)
    else
        SalmonUtils:setStatusBarVisible(false)
    end
end

function SalmonUtils:captureImage(captureName, handler)
	--print("警告：SalmonUtils:captureImage IOS接口未实现"..captureName)
    -- print("captureImage")
     if not captureName then
        captureName = "/image.png"
    end
    captureName = "/"..captureName

    local function callback( path )
    --    showStatusBar()
        if handler then
            handler(path)
        end
    end

    local args = {scriptHandler = callback, imageName = captureName}
    local ok,ret  = luaoc.callStaticMethod(className,"captureImage",args)
    if not ok then
        print("luaoc error:", ret)
    else
        SalmonUtils:setStatusBarVisible(false)
    end
end

-- 获取缓存大小
function SalmonUtils:getTotalCacheSize()
	-- print("警告：SalmonUtils:getTotalCacheSize IOS接口未实现")
    local ok,ret  = luaoc.callStaticMethod(className,"getTotalCacheSize")
    if not ok then
        print("luaoc error:", ok)
    else
        print("The ret is:", ret)
        return ret.."m"
    end
	return "0.0m"
end

-- 清除所有缓存
function SalmonUtils:clearAllCache()
	-- print("警告：SalmonUtils:clearAllCache IOS接口未实现")
    local ok,ret  = luaoc.callStaticMethod(className,"clearAllCache")
    if not ok then
        print("luaoc error:", ok)
    else
        print("The ret is:", ret)
    end
end

-- 获取所在城市
function SalmonUtils:getCNBylocation(handler)
	-- print("警告：SalmonUtils:getCNBylocation IOS接口未实现")
	-- local function cb(cityname)
	-- 	print("返回城市名字:", cityname)
	-- end
    print("获取所在城市")
	local args = {scriptHandler = handler}
    local ok,ret  = luaoc.callStaticMethod(className,"getCNBylocation", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end


	return "未定位"
end

function SalmonUtils:isOpenFlashLight()
    return SalmonUtils.isFlashOn
end

-- 打开闪光灯
function SalmonUtils:openFlashLight()
	-- print("警告：SalmonUtils:openFlashLight IOS接口未实现")
	local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"openFlashLight")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        SalmonUtils.isFlashOn = true
    end
end

--关闭闪光灯
function SalmonUtils:closeFlashLight()
	-- print("警告：SalmonUtils:closeFlashLight IOS接口未实现")
	local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"closeFlashLight")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        SalmonUtils.isFlashOn = false
    end

end

-- 复制字符
function SalmonUtils:copy(_content)
	-- print("警告：SalmonUtils:copy IOS接口未实现")
	local args = {content = _content}
    local ok,ret  = luaoc.callStaticMethod(className,"copy", args)
    if not ok then
        print("luaoc error:", ok)
    else
        KE_SetTimeout(1, function() utils.TellMe("复制成功") end)
    end
end

function SalmonUtils:paste()
	-- print("警告：SalmonUtils:paste IOS接口未实现")
    local ok,ret  = luaoc.callStaticMethod(className,"paste")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
	return ""
end

--[[横竖屏幕切换
     type: 1横 2 竖
]]
function SalmonUtils:setOrientation(typ)
    local args = {typ = typ}
    local ok,ret  = luaoc.callStaticMethod(className,"setOrientation", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
    SalmonUtils:resetGLView(typ)
end

function SalmonUtils:setOrientationEnable(b)
    local args = {isEnable = b}
    local ok,ret  = luaoc.callStaticMethod(className,"setOrientationEnable", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
end


function SalmonUtils:getOrientationEnable()
    -- assert(false, "SalmonUtils:getOrientationEnable()暂时不可用")
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getOrientationEnable")
    if not ok then
        print("luaoc error:", ok)
        return ret
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:setStatusBarVisible(isShow)
    -- assert(false, "SalmonUtils:getOrientationEnable()暂时不可用")
    local args = {isShow=isShow}
    local ok,ret  = luaoc.callStaticMethod(className,"setStatusBarVisible", args)
    if not ok then
        print("luaoc error:", ok)
        return ret
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:setScreenHandler(h)
    local args = {handler = h}
    local ok,ret  = luaoc.callStaticMethod(className,"setScreenHandler", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
end


-- 设置网络状态监听回调
function SalmonUtils:setNetworkChangeEvent(h)
    local function onNetworkChange(connType, nwType, rat)
        local data = {status=connType, networkType=nwType, rat = rat}
        h(data)
    end

    local args = {handler = onNetworkChange}
    local ok,ret  = luaoc.callStaticMethod(className,"setNetworkChangeEvent", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
    end
end


function SalmonUtils:getConnectedType()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getConnectedType")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
end

-- 摄像头权限
function SalmonUtils:cameraAuthorization()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"cameraAuthorization")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 摄像头权限
function SalmonUtils:audioAuthorization()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"audioAuthorization")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 摄像头权限
function SalmonUtils:cameraAuthCode()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"cameraAuthCode")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 摄像头权限
function SalmonUtils:audioAuthCode()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"audioAuthCode")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

--[[ 状态栏显示隐藏
]]
function SalmonUtils:setStatusBarVisible(isShow, handler)
    local args = {isShow=isShow, handler=handler}
    local ok,ret  = luaoc.callStaticMethod(className,"setStatusBarVisible", args)
    if not ok then
        print("luaoc error:", ok)
    else
        return ret
    end
end

function SalmonUtils:getStatusBarHeight()
    -- local args = {isShow=isShow, handler=handler}
    local ok,ret  = luaoc.callStaticMethod(className,"getStatusBarHeight")
    if not ok then
        print("luaoc error:", ok)
    else
        local glView = cc.Director:getInstance():getOpenGLView()
        ret = ret * 2 / glView:getScaleY() -- 临时解决方案
        return ret
    end
    return 0
end

-- 是否保持常亮
function SalmonUtils:setIsKeepWake(isKeepWake)
    local args = {isKeepWake=isKeepWake}
    local ok,ret  = luaoc.callStaticMethod(className,"setIsKeepWake", args)
    if not ok then
        print("luaoc error:", ok)
    else
        return ret
    end
    return 0
end

-- 获取定位权限
function SalmonUtils:getLocationAuth()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getLocationAuth")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

function SalmonUtils:locationAuthorization()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"locationAuthorization")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return AVPermission.Denied
end

function SalmonUtils:thirdPlatformPay(payInfo, payType)
    -- body
    local args = {payInfo=payInfo, payType = payType}
    local ok,ret  = luaoc.callStaticMethod(className,"thirdPlatformPay", args)
    if not ok then
        print("luaoc error:", ok)
    else
        return ret
    end
end

function SalmonUtils:aliAuthor(authorData)
    local args = {authorInfo = authorData}
    local ok,ret  = luaoc.callStaticMethod(className,"aliAuthor", args)
    if not ok then
        print("luaoc error:", ok)
    else
        return ret
    end
end

--print("ios获取渠道id")
function SalmonUtils:getInfoDataByKey(_key)
    local args = {key = _key}
    local ok,ret  = luaoc.callStaticMethod(className,"getInfoDataByKey",args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return ""
end

function SalmonUtils:getVersionName()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getVersionName")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function  SalmonUtils:getNotifyCategoryType()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getNotifyCategoryType")
    if not ok then
        print("luaoc error:", ok)
    elseif ret then
        return ret
    end
end


function SalmonUtils:getOpenUrlData()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getOpenUrlDic")
    if not ok then
        print("luaoc error:", ok)
    elseif ret then
        local beg, endp = string.find(ret, "roomId=(%w+)*")
        local id
        local url
        if beg and endp then
            print(string.format("beg = %d, endp = %d", beg, endp))
            id = string.sub(ret, beg + 7, endp - 1)
        end
        local beg2, endp2 = string.find(ret, "*liveUrl=(%w+)")
        if beg2 and endp2 then
            print(string.format("beg2 = %d, endp2 = %d", beg2, endp2))
            url = string.sub(ret, beg2+9, string.len(ret))
        end
        local data = {}
        if id and url then
            data.roomId = tonumber(id)
            data.url = url
            print_r(data)
            return data
        else
            return nil
        end  
    end
    return nil
end

function SalmonUtils:getDeviceIdentity()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getIdentifier")
    if not ok then
        print("luaoc error:", ok)
    else
        return ret
    end
    return nil
end

function SalmonUtils:getDeviceToken()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getDeviceToken")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function SalmonUtils:getDeviceModel( )
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(osinfoClassName,"getPhoneModel")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function SalmonUtils:getDeviceOsVersion()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(osinfoClassName,"getPhoneOSVersion")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function SalmonUtils:getResVersion()
    local resVersionStr = readFile("version.txt")
    local resVersion
    if resVersionStr then
        resVersion = loadstring(resVersionStr)
        local versionTable = resVersion()
        if versionTable and versionTable.version then
            return versionTable.version
        end
    end
    return nil
end


function SalmonUtils:getIpv4Address()
	local args = {}
    local ok,ret  = luaoc.callStaticMethod(className,"getIpv4Address", args)
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function SalmonUtils:getDeviceData()
    if not self.m_deviceData then
        self.m_deviceData = {}
        self.m_deviceData.Ip = SalmonUtils:getIpv4Address()
        --[[
        self.m_deviceData.DeviceOs = "ios"
        self.m_deviceData.DeviceImei = SalmonUtils:getDeviceIdentity()
        self.m_deviceData.DeviceToken = SalmonUtils:getDeviceToken()
        self.m_deviceData.Channel = SalmonUtils:getChannelId()
        self.m_deviceData.Network = SalmonUtils:getConnectedType()
        self.m_deviceData.Isp = SalmonUtils:getDeviceModel()
        self.m_deviceData.DeviceOsVersion = SalmonUtils:getDeviceOsVersion()
        self.m_deviceData.DevicePhoneModel = self.m_deviceData.Isp
        self.m_deviceData.Version = SalmonUtils:getVersionName()
        self.m_deviceData.ResourceVersion = SalmonUtils:getResVersion()
        ]]--
    end
--    utils.TellMe("IP: "..self.m_deviceData.Ip)
    return self.m_deviceData
end

function SalmonUtils:getStatisticsDeviceData()
    if not self.m_statisticData then
        self.m_statisticData = {}
        self.m_statisticData.Os = "ios"
        self.m_statisticData.OsVersion = SalmonUtils:getDeviceOsVersion()
        self.m_statisticData.PhoneModel = SalmonUtils:getDeviceModel()
        self.m_statisticData.Version = SalmonUtils:getVersionName()
        self.m_statisticData.Channel = SalmonUtils:getChannelId()
    end
    return self.m_statisticData
end

function  SalmonUtils:preLoginStatisticReq(actType, page, Locate)
    function cb(receiveData)
        print("runAdCoverSp statistics")
    end
    local url = HttpUtil:getUrl().."/logger/ui/access"
    local deviceData = SalmonUtils:getStatisticsDeviceData() or {}
    deviceData.AdtType = tostring(actType)
    deviceData.page = page
    deviceData.Locate = Locate
    HttpUtil:send(deviceData, cb, nil, url)
end
        
function SalmonUtils:getChannelId( )
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(osinfoClassName,"getChannelId")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

-- 设置状态栏点击事件
function SalmonUtils:setStatusBarEventHandler(handler)
    local args = {scriptHandler=handler}
    local ok,ret  = luaoc.callStaticMethod(className,"setStatusBarEventHandler", args)
    if not ok then
        print("luaoc error:", ok)
    end
end

function SalmonUtils:getBundleId()
    local args = {}
    local ok,ret  = luaoc.callStaticMethod(osinfoClassName,"getAppID")
    if not ok then
        print("luaoc error:", ok)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return nil
end

function SalmonUtils:umengAnalyticsEvent(eventId, platform)
    if comparCurVersion(VERSION_USE_UMENGSTATISTIC) then
        local args = {eventId = eventId, param = platform}
        local ok,ret  = luaoc.callStaticMethod(className,"umengAnalyticsEvent", args)
        if not ok then
            print("luaoc error:", ok)
        end
    end
    return nil
end

function SalmonUtils:appTrackRegister(uid)
    if comparCurVersion(VERSION_USE_UMENGSTATISTIC) then
        local args = {userId = tostring(uid)}
        local ok,ret  = luaoc.callStaticMethod(className,"accountCreate", args)
        if not ok then
            print("luaoc error:", ok)
        end
    end
    return nil
end

function SalmonUtils:onProfileSignIn(Provider, uid)
    if comparCurVersion(VERSION_USE_UMENGSTATISTIC) then
        local args = {provider = Provider, uid = tostring(uid)}
        local ok,ret  = luaoc.callStaticMethod(className,"onUserLogin", args)
        if not ok then
            print("luaoc error:", ok)
        end
    end
    return nil
end

function SalmonUtils:onProfileSignOff()
    if comparCurVersion(VERSION_USE_UMENGSTATISTIC) then
        local args = {}
        local ok,ret  = luaoc.callStaticMethod(osinfoClassName,"onUserLogout")
        if not ok then
            print("luaoc error:", ok)
        else
            -- print("The ret is:", ret)
            return ret
        end
    end
    return nil
end
