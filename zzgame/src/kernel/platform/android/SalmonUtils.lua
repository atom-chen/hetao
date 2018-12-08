if device.platform ~= "android" then return end

local luaj = require "cocos.cocos2d.luaj"
local className = "ppasist.utils.SalmonUtils"

SalmonUtils = {}

function SalmonUtils:fixUrl2utf8(url)
    return url
end

function SalmonUtils:openAnotherApp(packname, appname)
	local args = {packname, appname}
    local sigs = "(Ljava/lang/String;Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(className, "openAnotherApp" , args, sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

function SalmonUtils:getKeyboardHei()
    local ok,ret  = luaj.callStaticMethod("org.cocos2dx.lua.AppActivity", "getSoftKeyboardHeight" , {}, "()I")
    if ok then
        return ret
    else
        return 0
    end
end

-- 设置音量大小
function SalmonUtils:setVolume(percent)
	local args = {percent}
    local sigs = "(F)V"
    local ok,ret  = luaj.callStaticMethod(className,"setVolume",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 设置亮度
function SalmonUtils:setBrightness(percent)
	local args = {percent}
    local sigs = "(F)V"
    local ok,ret  = luaj.callStaticMethod(className,"setBrightness",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 获取音量大小
function SalmonUtils:getVolume()
    local args = {}
    local sigs = "()F"
    local ok,ret  = luaj.callStaticMethod(className,"getVolume",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        return ret
    end
end

function SalmonUtils:getBrightness()
    local args = {}
    local sigs = "()F"
    local ok,ret  = luaj.callStaticMethod(className,"getBrightness",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        return ret
    end
end

-- 保存相片到相册  by wolf
function SalmonUtils:saveImageToPhotos(handler, captureName)
    local args = {captureName, handler}
    local sigs = "(Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(className,"saveImageToPhotos",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 打开图库选取一张图
function SalmonUtils:openGallery(handler, captureName)
    if not captureName then
        captureName = "image.jpg"
    end

    local function getImgCb(path)
        if handler and path then
            local suffix = path:match(".+%.(%w+)$")
            if suffix == "gif" then
                -- TipsMgr:showSingleTips("暂不支持gif")
                handler(nil)
                return
            end
            if #path == 0 then
                -- TipsMgr:showSingleTips("找不到图片路径")
            end
            handler(path)
        end
    end

	local args = {captureName, getImgCb}
    local sigs = "(Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(className,"openGallery",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 拍照
function SalmonUtils:captureImage(captureName, handler)
	local args = {captureName, handler}
    local sigs = "(Ljava/lang/String;I)V"
    local ok,ret  = luaj.callStaticMethod(className,"captureImage",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 获取缓存大小
function SalmonUtils:getTotalCacheSize()
	local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getTotalCacheSize",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
	    return ret
    end
    return "0.0KB"
end

-- 清除所有缓存
function SalmonUtils:clearAllCache()
	local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"clearAllCache",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
    end
end

-- 获取所在城市
function SalmonUtils:getCNBylocation(handler)
    local function locationHandler(str)
    	local json = require("kernel.framework.json")
        local data = json.decode(str)
        handler(data.cityName, data.errorCode, data.longitude, data.latitude)
    end

    local args = {locationHandler}
    local sigs = "(I)Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getCNBylocation",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return "未定位"
end

function SalmonUtils:getLocationAuth()
    
    -- local args = {locationHandler}
    -- local sigs = "(I)Ljava/lang/String;"
    -- local ok,ret  = luaj.callStaticMethod(className,"getCNBylocation",args,sigs)
    -- if not ok then
    --     print("luaj error:", ret)
    -- else
    --     -- print("The ret is:", ret)
    --     return ret
    -- end
    -- return "未定位"
    return AVPermission.Authorized
end

function SalmonUtils:isOpenFlashLight()
    return SalmonUtils.isFlashOn
end

-- 打开闪光灯
function SalmonUtils:openFlashLight()
    local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"openFlashLight",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        SalmonUtils.isFlashOn = true
    end
end

--关闭闪光灯
function SalmonUtils:closeFlashLight()
    local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"closeFlashLight",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        SalmonUtils.isFlashOn = false
    end
end

-- 复制字符
function SalmonUtils:copy(content)
    local args = {content}
    local sigs = "(Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(className,"copy",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        KE_SetTimeout(1, function() utils.TellMe("复制成功") end)
    end
end

-- 黏贴
function SalmonUtils:paste()
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"paste",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("The ret is:", ret)
        return ret
    end
    return ""
end

function SalmonUtils:getAllPhoneNums()
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getAllPhoneNums",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("ret is :", ret)
        local json = require("kernel.framework.json")
        print_r(json.decode(ret), "The ret is:")
        return ret
    end
    return ""
end

-- 设置上传回调函数
function SalmonUtils:setUploadHandler(handler)
    local args = {handler}
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(className,"setUploadHandler",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

-- 上传
function SalmonUtils:upload(filename, key, token)
    local args = {filename, key, token}
    local sigs = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(className,"upload",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

-- 取消上传
function SalmonUtils:uploadCancel()
    local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"uploadCancel",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

-- 复制文件夹到可写目录
function SalmonUtils:copyToWritablePath(dir)
    local args = {dir}
    local sigs = "(Ljava/lang/String;)V"
    local ok,ret  = luaj.callStaticMethod(className,"copyToWritablePath",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

function SalmonUtils:setOrientation(type)
    if ScreenMgr:isSettingOrientation() then return end
    local args = {type}
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(className,"setOrientation",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        SalmonUtils:resetGLView(type)
        return ret
    end
    return ""
end

--[[ 状态栏显示隐藏
]]
function SalmonUtils:setStatusBarVisible(isShow, handler)
    -- local function luaHandler(str)
    --     local data = json.decode(str)
    --     if handler then
    --         handler(data.width, data.height)
    --     end
    -- end
    -- local args = {isShow, luaHandler}
    -- local sigs = "(ZI)V"
    -- local ok,ret  = luaj.callStaticMethod(className,"setStatusBarVisible",args,sigs)
    -- if not ok then
    --     print("luaj error:", ret)
    -- else
    --     -- print("ret is :", ret)
    --     return ret
    -- end
    -- return ""
end


--[[打开Gps设置界面
]]
function SalmonUtils:openGpsSetting()
    local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"openGpsSetting",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

function SalmonUtils:setTransparentStatusBar()
    local args = {}
    local sigs = "()V"
    local ok,ret  = luaj.callStaticMethod(className,"setTransparentStatusBar",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return ""
end

function SalmonUtils.onOrientationChange(str)
	local json = require("kernel.framework.json")
    local data = json.decode(str)
    SalmonUtils.orientationHandler(data.orientation, data.width, data.height)
end

-- 设置屏幕工具lua回调
function SalmonUtils:setScreenHandler(handler)
    self.orientationHandler = handler
    local args = {SalmonUtils.onOrientationChange}
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(className,"setScreenHandler",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
    end
end

function SalmonUtils:getWindowRect()
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getWindowRect",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("ret is :", ret)
        local json = require("kernel.framework.json")
        local datas = json.decode(ret)
        -- print_r(datas, "窗口大小")
        -- print("ret is :", datas.width, datas.height)
        return datas, ret
    end
end

-- 设置网络状态监听回调
function SalmonUtils:setNetworkChangeEvent(handler)

    local function onNetworkChange(str)
        local datas = json.decode(str)
        handler(datas)
    end

    local args = {onNetworkChange}
    local sigs = "(I)V"
    local ok,ret  = luaj.callStaticMethod(className,"setNetworkChangeEvent",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
    end
end

-- 获取设备当前连接类型
function SalmonUtils:getConnectedType()
    local args = {onNetworkChange}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"getConnectedType",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return 0
end

-- 获取摄像头权限状态
function SalmonUtils:cameraAuthCode()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"cameraAuthCode",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 获取摄像头权限状态
function SalmonUtils:cameraAuthorization()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"cameraAuthorization",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 获取摄像头权限状态
function SalmonUtils:audioAuthorization()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"audioAuthorization",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return AVPermission.Denied
end

-- 获取摄像头权限状态
function SalmonUtils:audioAuthCode()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"audioAuthCode",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        return ret
    end
    return AVPermission.Denied
end

function SalmonUtils:getStatusBarHeight()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"getStatusBarHeight",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        -- print("ret is :", ret)
        --print("状态栏高度:", ret)
        local glView = cc.Director:getInstance():getOpenGLView()
        return ret/glView:getScaleY()
    end
    return 0
end

function SalmonUtils:numberOfCameras()
    local args = {}
    local sigs = "()I"
    local ok,ret  = luaj.callStaticMethod(className,"numberOfCameras",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        return ret
    end
    return 2
end

-- 设置是否保持屏幕常亮
function SalmonUtils:setIsKeepWake(isKeepWake)
    local args = {isKeepWake}
    local sigs = "(Z)V"
    local ok,ret  = luaj.callStaticMethod(className,"setIsKeepWake",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
    end
end

function SalmonUtils:isEmulator()
    local args = {}
    local sigs = "()Z"
    local ok,ret  = luaj.callStaticMethod(className,"isEmulator",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        return ret
    end
    return false
end

function SalmonUtils:getInfoDataByKey(_key)
    local args = {_key}
    local sigs = "(Ljava/lang/String;)Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getInfoDataByKey",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("channelId is :", ret)
        return ret
    end
    return ""
end

--获取版本名称
function SalmonUtils:getVersionName()
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod(className,"getVersionName",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("ret is :", ret)
        return ret
    end
    return nil
end


function SalmonUtils:getOpenUrlData()
  
end


function  SalmonUtils:getNotifyCategoryType()
    
end

--获取手机IMEI
function SalmonUtils:getDeviceIdentity()
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod("ppasist.utils.OSInfoUtils","getPhoneIMEI",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("ret is :", ret)
        return ret
    end
    return nil
end

--用户登录统计
function SalmonUtils:accountLoginStatistics( uid )
  
end

function SalmonUtils:accountLogoutStatistics(  )
    
end

function SalmonUtils:getDeviceToken()
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

function SalmonUtils:getDeviceData()
    if not self.m_deviceData then
        self.m_deviceData = {}
        self.m_deviceData.DeviceOs = "android"
    --    self.m_deviceData.DeviceImei = SalmonUtils:getDeviceIdentity()
    --    self.m_deviceData.DeviceToken = SalmonUtils:getDeviceToken()
    --    self.m_deviceData.Channel = SalmonUtils:getChannelId()
    --    self.m_deviceData.Network = SalmonUtils:getConnectedType()
    --    self.m_deviceData.ResourceVersion = SalmonUtils:getResVersion()
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local ok,ret  = luaj.callStaticMethod("ppasist.utils.OSInfoUtils","getDeviceInfo",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
           if ret then
           		local json = require("kernel.framework.json")
                local info = json.decode(ret)
                if info.deviceModel and info.deviceVersion then
                    self.m_deviceData.DevicePhoneModel = info.deviceModel
                    self.m_deviceData.DeviceOsVersion = info.deviceVersion
                end
                if info.versionName then
                    self.m_deviceData.Version = info.versionName
                end
                if info.macAddr and info.ipAddr then
                    self.m_deviceData.DeviceMac = info.macAddr
                    self.m_deviceData.Ip = info.ipAddr
                end
                if info.isp then
                    self.m_deviceData.Isp = info.isp
                end
           end
        end
    end
    return self.m_deviceData
end

function SalmonUtils:getStatisticsDeviceData()
    if not self.m_statisticData then
        self.m_statisticData = {}
        self.m_statisticData.Os = "android"
        self.m_statisticData.Channel = SalmonUtils:getChannelId()
        self.m_statisticData.Imei = SalmonUtils:getDeviceIdentity()
        local args = {}
        local sigs = "()Ljava/lang/String;"
        local ok,ret  = luaj.callStaticMethod("ppasist.utils.OSInfoUtils","getDeviceInfo",args,sigs)
        if not ok then
            print("luaj error:", ret)
        else
           if ret then
                local info = json.decode(ret)
                if info.deviceModel and info.deviceVersion then
                    self.m_statisticData.PhoneModel = info.deviceModel
                    self.m_statisticData.OsVersion = info.deviceVersion
                end
                if info.versionName then
                    self.m_statisticData.Version = info.versionName
                end
                if info.macAddr then
                    self.m_statisticData.Mac = info.macAddr
                end
           end
        end    
    end
    return self.m_statisticData
end

function SalmonUtils:preLoginStatisticReq(actType, page, Locate)
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

--获取渠道信息
function SalmonUtils:getChannelId( )
    local args = {}
    local sigs = "()Ljava/lang/String;"
    local ok,ret  = luaj.callStaticMethod("ppasist.utils.OSInfoUtils","getChannelId",args,sigs)
    if not ok then
        print("luaj error:", ret)
    else
        print("ret is :", ret)
        return ret
    end
    return nil
end

function SalmonUtils:getBundleId()
    return nil
end

function SalmonUtils:umengAnalyticsEvent(eventId, platform)
    return nil
end

function SalmonUtils:appTrackRegister(uid)
    return nil
end

function SalmonUtils:onProfileSignIn(Provider, UID)
    return nil
end

function SalmonUtils:onProfileSignOff()
    return nil
end