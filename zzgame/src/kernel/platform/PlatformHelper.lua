---------------------------------------
-- 平台相关接口
---------------------------------------
local className = "org.cocos2dx.lua.AppActivity"

PlatformHelper = {}

function PlatformHelper.IsSysWindows()
	return device.platform == "windows"
end
function PlatformHelper.IsSysAndroid()
	return device.platform == "android"
end
function PlatformHelper.IsSysIos()
	return device.platform == "ios"
end

local socket = require("socket")
local function GetAdd(hostname)
	local ip, resolved = socket.dns.toip(hostname)
	local ListTab = {}
	if resolved and resolved.ip then
		for k, v in ipairs(resolved.ip) do
			table.insert(ListTab, v)
		end
	end
	return ListTab
end
function PlatformHelper:GetIpAddress()
	local ipAddr = unpack(GetAdd(socket.dns.gethostname()))
	print("=======", ipAddr, type(ipAddr))
	return ipAddr
end

function PlatformHelper.openURL(url)
	if not url or url == "" then
		return
	end
	cc.Application:getInstance():openURL(url)
end

function PlatformHelper.closeSystemKeyboard(edtbox)
	if device.platform == "android" then
		luaj.callStaticMethod(className, "closeSystemKeyboard", { }, "()V")
	else 
		if utils.IsValidCCObject(edtbox) then
			edtbox:setVisible(false)
			edtbox:setVisible(true)
		end
	end
end

function PlatformHelper.CheckCamera()
	if device.platform == "android" then
		luaj.callStaticMethod("ppasist.utils.AuthorUtils", "CheckCamera", { }, "()Z")
	end
end

function PlatformHelper.getLocalInfo()
	local localInfo = { }
	if device.platform == "android" then
		localInfo.bPlatform = 1
		localInfo.szChannel = ""
		localInfo.szVersion = "1.0.2"

		local ok, ret = luaj.callStaticMethod(className, "getImsi", { }, "()Ljava/lang/String;")
		if ok then
			localInfo.szImsi = ret
		else
			localInfo.szImsi = string.format("%015d", math.random(0, 10000000000))
		end

		ok, ret = luaj.callStaticMethod(className, "getImei", { }, "()Ljava/lang/String;")
		if ok then
			localInfo.szImei = ret
		else
			localInfo.szImei = string.format("46%013d", math.random(0, 10000000000))
		end

		ok, ret = luaj.callStaticMethod(className, "getModel", { }, "()Ljava/lang/String;")
		if ok then
			localInfo.szModel = ret
		else
			localInfo.szModel = ""
		end

		ok, ret = luaj.callStaticMethod(className, "getVersion", { }, "()Ljava/lang/String;")
		if ok then
			localInfo.szVersion = ret
		else
			localInfo.szVersion = "1.0.2"
		end

		ok, ret = luaj.callStaticMethod(className, "getChannel", { }, "()Ljava/lang/String;")
		if ok then
			localInfo.szChannel = ret
		else
			localInfo.szChannel = "1.0.2"
		end
	elseif device.platform == "ios" then
		localInfo.bPlatform = 2
		localInfo.wChannel = 0
		localInfo.szVersion = "1.0.2"

		local ok, ret = luaoc.callStaticMethod("AppController", "getImsi", { })
		if ok then
			localInfo.szImsi = ret
		else
			localInfo.szImsi = string.format("%015d", math.random(0, 10000000000))
		end

		ok, ret = luaoc.callStaticMethod("AppController", "getImei", { })
		if ok then
			localInfo.szImei = ret
		else
			localInfo.szImei = string.format("46%013d", math.random(0, 10000000000))
		end

		ok, ret = luaoc.callStaticMethod("AppController", "getModel", { })
		if ok then
			localInfo.szModel = ret
		else
			localInfo.szModel = ""
		end
		ok, ret = luaoc.callStaticMethod("AppController", "getVersion", { })
		if ok then
			localInfo.szVersion = ret
		else
			localInfo.szVersion = "1.0.2"
		end
		ok, ret = luaoc.callStaticMethod("AppController", "getChannel", { })
		if ok then
			localInfo.szChannel = ret
		else
			localInfo.szChannel = "1.0.2"
		end
	elseif device.platform == "mac" then
		localInfo.bPlatform = 3
		localInfo.szChannel = "HW0001"
		localInfo.szVersion = "1.0.2"
		localInfo.szImsi = "460000001233456334"
		localInfo.szImei = "678956712323456345"
		localInfo.szModel = "xiaomi123345"
	elseif device.platform == "windows" then
		localInfo.bPlatform = 3
		localInfo.szChannel = "HW0001"
		localInfo.szVersion = "1.0.2"
		localInfo.szImsi = "460000001233456334"
		localInfo.szImei = "678956712323456345"
		localInfo.szModel = "xiaomi123345"
	end
	return localInfo
end

function PlatformHelper.vibrate(count)
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(className, "vibrate", { count }, "(I)V")
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("AppController", "vibrate", { count = count })
	elseif device.platform == "mac" then
	
	elseif device.platform == "windows" then

	end
end

function PlatformHelper.getVersion()
	if device.platform == "android" then
		local ok, ret = luaj.callStaticMethod(className, "getVersion", { }, "()Ljava/lang/String;")
		if ok then
			return "V" .. ret
		else
			return "V1.0.0"
		end
	elseif device.platform == "ios" then
		local ok, ret = luaoc.callStaticMethod("AppController", "getVersion", { })
		if ok then
			return "V" .. ret
		else
			return "V1.0.0"
		end
	elseif device.platform == "mac" then
		return "V1.5.0"
	elseif device.platform == "windows" then
		return "V1.5.0"
	end
end

function PlatformHelper.isInstallWX()
    if device.platform == "android" then
        if true then
            return 1
        end
        local ok, ret = luaj.callStaticMethod(className, "isInstallWX", { }, "()I")
        if ok then
            return ret
        else
            return false
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "isInstallWX", { })
        if ok then
            return ret
        else
            return false
        end
    elseif device.platform == "mac" then
        return false
    elseif device.platform == "windows" then
        return false
    end
end

function PlatformHelper.onGameLauch()
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(className, "onGameLauch", { }, "()V")
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "onGameLauch", { })
    elseif device.platform == "windows" then

    else

    end
end

function PlatformHelper.isNetworkConnected()
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(className, "isNetworkConnected", { }, "()Z")
        return ret
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "isNetworkConnected", { })
        return ret == 1 and true or false
    elseif device.platform == "windows" then

    else

    end
    return true
end


function PlatformHelper.onPageEvent(id, name)
    local tbParam = { name = name }
    if device.platform == "android" then
        tbParam = json.encode(tbParam)
        tbParam = { tbParam }
        local ok, ret = luaj.callStaticMethod(className, "onPageEvent", tbParam, "(Ljava/lang/String;)V")
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "onRegister", tbParam)
    else
        tbParam = json.encode(tbParam)
        tbParam = { tbParam }
    end
end

-- mode  0 系統控制  1 游戏控制
function PlatformHelper.setKeyboardAutoCloseMode(mode)
    if device.platform == "android" then
        utils.callJavaFunc(className, "setKeyboardAutoCloseMode", { mode }, "(I)V")
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "setKeyboardAutoCloseMode", { mode = mode })
    end
end 
function PlatformHelper.getKeyboardAutoCloseMode()
    if device.platform == "android" then
        local ok, ret = utils.callJavaFunc(className, "getKeyboardAutoCloseMode", { }, "(V)I")
        if ok then
            return ret;
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "getKeyboardAutoCloseMode", { })
        if ok then
            return ret;
        end
    end
    return 0
end 

function PlatformHelper.isKeyboardShow()
    if device.platform == "android" then
        return false
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "isKeyboardShow", { })
        return ret == 1 and true or false
    end
end

function PlatformHelper.getOpenUrlJson()
    if device.platform == "android" then
        local ok, ret = utils.callJavaFunc(className, "getOpenUrlJson", { }, "()Ljava/lang/String;")
        if ok then
            return ret;
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "getOpenUrlJson", { })
        if ok then
            return ret;
        end
    end
    return ""
end 

function PlatformHelper.clearOpenUrlJson()
    if device.platform == "android" then
        local ok, ret = luaj.callStaticMethod(className, "clearOpenUrlJson", { }, "()V")
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "clearOpenUrlJson", { })
    elseif device.platform == "windows" then

    else

    end
end

function PlatformHelper.getDeviceId()
    if device.platform == "android" then
        local ok, ret = utils.callJavaFunc(className, "getDeviceId", { }, "()Ljava/lang/String;")
        if ok then
            return ret;
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "getDeviceId", { })
        if ok then
            return ret;
        end
    end
    return ""
end 

function PlatformHelper.getModel()
    if device.platform == "android" then
        local ok, ret = utils.callJavaFunc(className, "getModel", { }, "()Ljava/lang/String;")
        if ok then
            return ret;
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "getModel", { })
        if ok then
            return ret;
        end
    end
    return ""
end 

function PlatformHelper.getBattery()
    if device.platform == "android" then
        local ok, ret = utils.callJavaFunc(className, "getBattery", { }, "()I")
        if ok then
            return g_battery;
        end
    elseif device.platform == "ios" then
        local ok, ret = luaoc.callStaticMethod("AppController", "getBattery", { })
        if ok then
            return ret;
        end
    end
    return 100
end

function PlatformHelper.httpGet(url, succCallback, failCallback, loadingCallback)
	if device.platform == "android" then
		local ok, ret = utils.callJavaFunc("ppasist.utils.HttpLua", "httpGet", { url, succCallback, failCallback, loadingCallback }, "(Ljava/lang/String;III)V")
	end
end

function PlatformHelper.httpPost(url, cont, succCallback, failCallback, loadingCallback)
	if device.platform == "android" then
		local ok, ret = utils.callJavaFunc("ppasist.utils.HttpLua", "httpPost", { url, cont, succCallback, failCallback, loadingCallback }, "(Ljava/lang/String;Ljava/lang/String;III)V")
	end
end

function PlatformHelper.setHeader(key, value)
	if device.platform == "android" then 
		local ok, ret = utils.callJavaFunc("ppasist.utils.HttpLua", "setHeader", {key, value}, "(Ljava/lang/String;Ljava/lang/String;)V")
	end
	PlatformHelper.addHeader("FROMWAY", const.FROMWAY)
end

function PlatformHelper.addHeader(key, value)
	if device.platform == "android" then 
		local ok, ret = utils.callJavaFunc("ppasist.utils.HttpLua", "addHeader", {key, value}, "(Ljava/lang/String;Ljava/lang/String;)V")
	end
end
