-------------------------
-- 本地缓存管理
-------------------------
local f_secret = "LHP0522pp"
local crypto = require("kernel.framework.crypto")
local json = require("kernel.framework.json")
local PrivateData = require("kernel.manager.PrivateData")
local GameCacheData = {}

ClsCacheManager = class("ClsCacheManager")
ClsCacheManager.__is_singleton = true

function ClsCacheManager:ctor()
	local stateListener = function(event)
		if event.errorCode then
			print("ERROR, load:" .. event.errorCode)
			return
		end
		local returnValue = nil
		if "load" == event.name then
			local str = crypto.decryptXXTEA(event.values.data, f_secret)
			returnValue = json.decode(str)
		elseif "save" == event.name then
			local str = json.encode(event.values)
			if str then
				str = crypto.encryptXXTEA(str, f_secret)
				returnValue = {data = str}
			else
				print("ERROR, encode fail")
				return
			end
		end
		return returnValue
	end
	PrivateData.init(stateListener, "ycdb", f_secret)
	
	if io.exists(PrivateData.getPrivateDataPath()) then
		GameCacheData = PrivateData.load() or {}
		dump(GameCacheData, "GameCacheData :")
	end
end

function ClsCacheManager:dtor()
    self:save()
end

function ClsCacheManager:save()
	PrivateData.save(GameCacheData)
end

function ClsCacheManager:getCacheData(cacheName, defaultValue)
	local cacheData = nil
	if GameCacheData ~= nil then
		cacheData = GameCacheData[cacheName]
	end
	if cacheData == nil and defaultValue ~= nil then
		return defaultValue
	end
	return cacheData
end

function ClsCacheManager:saveCacheData(cacheName, cacheData)
	dump(cacheData, " GameCache:saveCacheData : "..cacheName)
	if GameCacheData == nil or cacheName == nil or cacheData == nil then
		return
	end
	GameCacheData[cacheName] = cacheData
	self:save()
end

