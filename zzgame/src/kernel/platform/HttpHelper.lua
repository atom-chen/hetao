-----------------------------------------
--HTTP辅助类 Android OkHttp 3.2
-----------------------------------------
local luaj = 0
local className = "ppasist.utils.HttpLua"

if device.platform == "android" then 
	luaj = require "cocos.cocos2d.luaj"
	className = "ppasist.utils.HttpLua"
end


HttpHelper = {}

function HttpHelper:setHeader(key, value)
	if device.platform == "android" then 
		if not key then return end
		if not value then return end
		utils.callJavaFunc(className, "setHeader", {key, value}, "(Ljava/lang/String;Ljava/lang/String;)V")
	end
end

function HttpHelper:uploadHeadImg(url, filepath, succCallback, failCallback, loadingCallback)
	if device.platform == "android" then 
		if not url or url == "" then return end
		if not filepath or filepath == "" then return end
		HttpHelper:setHeader(HttpUtil:GetHttpHeadKey(), HttpUtil:GetHttpHeadValue())
		utils.callJavaFunc(className, "uploadHeadImg", {url,filepath,succCallback,failCallback,loadingCallback}, "(Ljava/lang/String;Ljava/lang/String;III)V")
	end
end 

function HttpHelper:bindWxZfb(url, filepath, strParam, succCallback, failCallback, loadingCallback)
	if device.platform == "android" then 
		if not url or url == "" then return end
		if not filepath or filepath == "" then return end
		if not strParam or strParam == "" then return end
		HttpHelper:setHeader(HttpUtil:GetHttpHeadKey(), HttpUtil:GetHttpHeadValue())
		utils.callJavaFunc(className, "bindWxZfb", {url, filepath, strParam, succCallback, failCallback, loadingCallback}, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;III)V")
	end
end