-------------------------
-- 简单的用户本地数据
-------------------------
UserDefaultData = {}

UserDefaultData._valueMap = {
	willquicklogon = "bool",
	username = "string",
	password = "string",
	soundonoff = "bool",
	shakeonoff = "bool",
	allusers = "table",
}

for k, valueType in pairs(UserDefaultData._valueMap) do
	if UserDefaultData._valueMap[k] == "string" then
		UserDefaultData["Set_"..k] = function(this, value)
			logger.normal("保存本地数据：", k, value)
			assert(type(value)=="string", "数据类型错误，类型应该为：string")
			ClsCacheManager.GetInstance():saveCacheData(k, value)
		end
		UserDefaultData["Get_"..k] = function(this, defaultValue)
			assert(defaultValue==nil or type(defaultValue)=="string", "数据类型错误，类型应该为：string")
			local ret = ClsCacheManager.GetInstance():getCacheData(k, defaultValue)
			logger.normal("取得本地数据：", k, ret)
			return ret
		end
	elseif UserDefaultData._valueMap[k] == "int" then
		UserDefaultData["Set_"..k] = function(this, value)
			logger.normal("保存本地数据：", k, value)
			assert(type(value)=="number", "数据类型错误，类型应该为：number")
			ClsCacheManager.GetInstance():saveCacheData(k, value)
		end
		UserDefaultData["Get_"..k] = function(this, defaultValue)
			assert(defaultValue==nil or type(defaultValue)=="number", "数据类型错误，类型应该为：number")
			local ret = ClsCacheManager.GetInstance():getCacheData(k, defaultValue)
			logger.normal("取得本地数据：", k, ret)
			return ret
		end
	elseif UserDefaultData._valueMap[k] == "bool" then
		UserDefaultData["Set_"..k] = function(this, value)
			logger.normal("保存本地数据：", k, value)
			assert(type(value)=="boolean", "数据类型错误，类型应该为：boolean")
			ClsCacheManager.GetInstance():saveCacheData(k, value)
		end
		UserDefaultData["Get_"..k] = function(this, defaultValue)
			assert(type(defaultValue)=="boolean", "数据类型错误，类型应该为：boolean")
			local ret = ClsCacheManager.GetInstance():getCacheData(k, defaultValue)
			logger.normal("取得本地数据：", k, ret)
			return ret
		end
	elseif UserDefaultData._valueMap[k] == "table" then
		UserDefaultData["Set_"..k] = function(this, value)
			logger.normal("保存本地数据：", k, value)
			assert(type(value)=="table", "数据类型错误，类型应该为：table")
			ClsCacheManager.GetInstance():saveCacheData(k, value)
		end
		UserDefaultData["Get_"..k] = function(this, defaultValue)
			assert(type(defaultValue)=="table", "数据类型错误，类型应该为：table")
			local ret = ClsCacheManager.GetInstance():getCacheData(k, defaultValue)
			logger.normal("取得本地数据：", k, ret)
			return ret
		end
	end
end
