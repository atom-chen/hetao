------------------
-- 图片下载管理
------------------
local crypto = require("kernel.framework.crypto")

ClsImageDownloader = class("ClsImageDownloader")
ClsImageDownloader.__is_singleton = true

function ClsImageDownloader:ctor()
	self._callbacks = {}
	self._asks = {}
end

function ClsImageDownloader:dtor()
    self._callbacks = {}
    self._asks = {}
end

function ClsImageDownloader:HasListener(callback)
	for k, v in pairs(self._callbacks) do
		for func,_ in pairs(v) do
			if func == callback then
				return true
			end
		end
	end
	return false
end

function ClsImageDownloader:GetImage(url, callback)
--	print("=====", url)
	local urlMd5 = crypto.md5(url)
	local cacheDir = GAME_CONFIG.LOCAL_DIR .. "/imgCache"
	local cachePath = cacheDir .. "/" .. urlMd5
		
	if not cc.FileUtils:getInstance():isDirectoryExist(cacheDir) then
		cc.FileUtils:getInstance():createDirectory(cacheDir)
	end
		
	if cc.FileUtils:getInstance():isFileExist(cachePath) then
		callback(cachePath)
		return cachePath
	end
	
	self._callbacks[urlMd5] = self._callbacks[urlMd5] or new_weak_table("kv")
	if not self:HasListener(callback) then
		self._callbacks[urlMd5][callback] = 1
	end
	if self._asks[urlMd5] then 
		KE_SetTimeout(30, function() self._asks[urlMd5] = nil end)
		return 
	end
	self._asks[urlMd5] = true
	
	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", url)
	local function onReadyStateChange()
		if xhr.readyState == 4 then
			if xhr.status == 200 then
				local respData = xhr.response

				FileHelper.CheckDir(cacheDir, true)
				
				local fHandle = io.open(cachePath, "wb")
				if fHandle then
					fHandle:write(respData)
					fHandle:close()
				end

				if cc.FileUtils:getInstance():isFileExist(cachePath) then
					if self._callbacks[urlMd5] then
						for func, _ in pairs(self._callbacks[urlMd5]) do
							func(cachePath)
						end
						self._callbacks[urlMd5] = {}
					end
				else
					logger.error("ImageView:LoadTextureSync: create file fail: ", cachePath)
				end
			else
				logger.error("ImageView:LoadTextureSync fail because net error: ", url)
			end
		else
			logger.error("ImageView:LoadTextureSync: fail because net fail: ", url)
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

function ClsImageDownloader:RemoveListener(callback)
	if not self._callbacks then return end
	for k, v in pairs(self._callbacks) do
		for func,_ in pairs(v) do
			if func == callback then
				self._callbacks[k] = nil
			end
		end
	end
end
