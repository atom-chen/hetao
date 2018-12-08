-------------------------
-- AI命令解析器
-------------------------
module("ai",package.seeall)

-- "ai_name,interval,arglist"
-- eg: "bt_hero_fight,1.2"
function ParseAiCmdStr(AiStr)
	if not AiStr or not string.find(AiStr, "%S") then return end
	
	local info = string.split(AiStr,",") or {}
	
	local ai_name = info[1]					--ai命令，和ai_rules中定义的行为树名字必须对应
	local interval = tonumber(info[2])		--执行周期（每多少秒执行一次该AI）
	local arglist = info[3]					--参数表
	
	assert(ai_name, string.format("解析失败: ",AiStr))
	assert(ClsBTFactory.GetInstance():GetBT(ai_name), string.format("无效的ai命令：%s",ai_name))
	assert(arglist==nil or type(arglist)=="table", string.format("无效的参数：",arglist))
	
	return { ai_name = ai_name, interval = interval, arglist = arglist }
end

function PackAiCmdStr(info)
	if type(info) ~= "table" then return end
	
	local ai_name = info.ai_name
	local interval = info.interval or ""
	local arglist = info.arglist
	
	assert(ai_name, string.format("解析失败: ",ai_name))
	assert(ClsBTFactory.GetInstance():GetBT(ai_name), string.format("无效的ai命令：%s",ai_name))
	if arglist then assert(table.is_array(arglist), "无效的参数") end
	
	local AiStr = ai_name..interval..table.to_online_string(arglist)
	logger.ai("PackAiCmdStr:", AiStr)
	return AiStr
end

