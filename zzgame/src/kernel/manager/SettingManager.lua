-------------------------
-- 配置表
-------------------------
module("setting", package.seeall)

function Get(sFilePath)
	return require(sFilePath)
end

function UnLoad(sFilePath)
	unquire(sFilePath)
end

function ReLoad(sFilePath)
	UnLoad(sFilePath)
	return self:Get(sFilePath)
end

------------------------------------------------------------------------------------------------------

T_multy_language = setting.Get("app.configs.xls.T_multy_language")
T_net_fail = setting.Get("app.configs.xls.T_net_fail")
T_guide_cfg = setting.Get("app.configs.xls.T_guide_cfg")
T_advertise = setting.Get("app.configs.xls.T_advertise")
T_lhc_sx = setting.Get("app.configs.xls.T_lhc_sx")
T_k3_wanfa_tip = setting.Get("app.configs.xls.T_k3_wanfa_tip")
T_all_wanfa = setting.Get("app.configs.xls.T_all_wanfa")
T_peilv_files = setting.Get("app.configs.xls.T_peilv_files")

function GetPeilvCfg(key)
	if not key then return nil end
	if T_peilv_files[key] then
		return setting.Get(T_peilv_files[key])
	else
		print("配置表中没有该赔率表：", key)
	end
	return nil
end

------------------------------------------------------------------------------------------------------

------------------
-- 多语言
------------------
if device.platform == "windows" then
	local language_map = {}
	for id, text in pairs(T_multy_language) do
		assert( not language_map[text], string.format("重复了：%s(%s和%s)",text,id,language_map[text]) )
		language_map[text] = id
	end
	assert(table.size(language_map)==table.size(T_multy_language), "多语言表有重复")
	language_map = nil
end 

function GetMultyMsg(msgId)
	assert(T_multy_language[msgId], "未配置多语言："..msgId)
	return T_multy_language[msgId]
end

------------------
--剧情
------------------
function GetStoryCfg(sStoryName)
	local filepath = string.format("app.configs.storys/%s", sStoryName)
	return setting.Get(filepath)
end
