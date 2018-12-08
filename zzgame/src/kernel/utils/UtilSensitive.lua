-------------------------
-- 辅助库
-------------------------
module("utils", package.seeall)

--是否全为空白字符
function IsWhiteSpace(Str)
	return not string.find(Str, "%S")
end

-- 变量名检测
function IsValidVarName(Name)
	if utils.IsWhiteSpace(Name) or string.gsub(Name, "[_%a][_%w]*", "") ~= "" then
		return false
	end
	return true
end

--敏感字检测
function SensitiveCheck(Str)
	local Forbidden = setting.Get("app.configs.T_sensitive_cfg.lua")
	
	Str = string.lower(Str)
	Str = string.gsub(Str, "[%w%c%s%p]+","")	--去除ASCII字符再进行判断
	
	local string_find = string.find 
	for _, s in pairs(Forbidden) do
		if string_find(Str, s, 1, true) then
			return false
		end
	end

	return true
end

--用户名检测
function IsValidUserName(Str)
	if IsWhiteSpace(Str) then 
		return false, "不可全为空白字符"
	end
	if not SensitiveCheck(Str) then 
		return false, "您输入了不合规定的字符"
	end
	return true 
end
