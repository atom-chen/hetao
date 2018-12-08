-------------------------
-- set和get方法注册
-- 计时器
-------------------------
local formator = string.format

clsCoreObject = class("clsCoreObject", clsEventSource)

-- 简化set和get函数的写法
function clsCoreObject:_reg_var(groupID, VarName, globalEventName, CheckFuncer)
	assert(type(VarName)=="string", "属性名必须为字符串")
	assert(globalEventName==nil or type(globalEventName)=="string", "事件名必须为字符串或nil")
	assert(type(CheckFuncer)=="function", "未定义数据类型检查方法")
	self._VAR_TYPE_TABLE = self._VAR_TYPE_TABLE or {}
	self._VAR_TYPE_TABLE[VarName] = CheckFuncer
	
	if globalEventName then
		self._VAR_EVENT_TABLE = self._VAR_EVENT_TABLE or {}
		self._VAR_EVENT_TABLE[VarName] = globalEventName
		g_EventMgr:RegisterEventType(globalEventName)
	--	logger.normal("注册全局事件", self.__cname, VarName, globalEventName or "nil")
	else 
		self:RegisterEventType(VarName)
	--	logger.normal("注册私有事件", self.__cname, VarName, globalEventName or "nil")
	end 
	
	--Set接口，值变化时分发事件
	assert(not self[formator("Set_%s",VarName)], formator("函数被覆盖: Set_%s",VarName))
	self[formator("Set_%s",VarName)] = function(this, Value)
		logger.normal(this.__cname.."设置属性", VarName, Value)
		local bSucc, tipStr = self._VAR_TYPE_TABLE[VarName](Value)
		if not bSucc then assert(false, string.format("%s %s",VarName,tipStr)) end
		local old_value = this[groupID][VarName]
		this[groupID][VarName] = Value
		if globalEventName then
			g_EventMgr:FireEvent(globalEventName, Value, old_value)
		else 
			this:FireEvent(VarName, Value, old_value)
		end 
	end
	--Set接口，不分发事件
	assert(not self[formator("Set_%s_Silent",VarName)], formator("函数被覆盖: Set_%s_Silent",VarName))
	self[formator("Set_%s_Silent",VarName)] = function(this, Value)
		logger.normal(this.__cname.."设置属性", VarName, Value)
		local bSucc, tipStr = self._VAR_TYPE_TABLE[VarName](Value)
		if not bSucc then assert(false, string.format("%s %s",VarName,tipStr)) end
		this[groupID][VarName] = Value
	end
	--Get接口
	assert(not self[formator("Get_%s",VarName)], formator("函数被覆盖: Get_%s",VarName))
	self[formator("Get_%s",VarName)] = function(this)
		return this[groupID][VarName]
	end
end
-- 注册存盘属性，参与属性序列化操作,会影响到最终obj的存盘数据结构
function clsCoreObject:RegSaveVar(VarName, CheckFuncer, globalEventName)
	CheckFuncer = CheckFuncer or TYPE_CHECKER.ANY
	self.__InitNetProps = true
	self:_reg_var("_netprops", VarName, globalEventName, CheckFuncer)
end
-- 注册临时属性，参与属性序列化行为，生命周期为在线
--function clsCoreObject:RegTmpOnlineVar(VarName, globalEventName, CheckFuncer)
--	CheckFuncer = CheckFuncer or TYPE_CHECKER.ANY
--	self.__InitTempOnlineVar = true
--	self:_reg_var("_tmponlines", VarName, globalEventName, CheckFuncer)
--end
-- 注册临时属性，不参与属性序列化操作，生命周期为当前所在场景
--function clsCoreObject:RegTmpVar(VarName, globalEventName, CheckFuncer)
--	CheckFuncer = CheckFuncer or TYPE_CHECKER.ANY
--	self.__InitTempVar = true
--	self:_reg_var("_tmpvars", VarName, globalEventName, CheckFuncer)
--end


function clsCoreObject:ctor()
	clsEventSource.ctor(self)
	if self.__InitNetProps then self._netprops = {} end
--	if self.__InitTempOnlineVar then self._tmponlines = {} end
--	if self.__InitTempVar then self._tmpvars = {} end
	self._tTimerList = {}			--存放计时器
end

function clsCoreObject:dtor()
	g_EventMgr:DelListener(self)
	g_EventMgr:DelListener(self.__cname)
	self:DestroyAllTimer()
end

--------------------------
-- 属性
--------------------------
function clsCoreObject:GetAttr(VarName)
	assert(self._VAR_TYPE_TABLE[VarName], "未定义的变量名："..VarName)
	return self._netprops[VarName]
end

function clsCoreObject:SetAttr(VarName, Value)
	logger.normal(self.__cname.."设置属性", VarName, Value)
	local bSucc, tipStr = self._VAR_TYPE_TABLE[VarName](Value)
	if not bSucc then assert(false, string.format("%s %s",VarName,tipStr)) end
	
	local old_value = self._netprops[VarName]
	self._netprops[VarName] = Value
	
	if self._VAR_EVENT_TABLE and self._VAR_EVENT_TABLE[VarName] then
		g_EventMgr:FireEvent(self._VAR_EVENT_TABLE[VarName], self, Value, old_value)
	else 
		self:FireEvent(VarName, self, Value, old_value)
	end 
end

function clsCoreObject:SetAttrSilent(VarName, Value)
	logger.normal(self.__cname.."设置属性", VarName, Value)
	local bSucc, tipStr = self._VAR_TYPE_TABLE[VarName](Value)
	if not bSucc then assert(false, string.format("%s %s",VarName,tipStr)) end
	self._netprops[VarName] = Value
end

function clsCoreObject:BatchSetAttr(tInfo)
	if tInfo == nil then return end
	for k, v in pairs(tInfo) do
		self:SetAttr(k, v)
	end
end

function clsCoreObject:FireProp(VarName, old_value)
	assert(self._VAR_TYPE_TABLE[VarName], "未定义的变量名："..VarName)
	if self._VAR_EVENT_TABLE and self._VAR_EVENT_TABLE[VarName] then
		g_EventMgr:FireEvent(self._VAR_EVENT_TABLE[VarName], self, self._netprops[VarName], old_value)
	else 
		self:FireEvent(VarName, self, self._netprops[VarName], old_value)
	end 
end

--------------------------
-- 计时器
--------------------------
function clsCoreObject:CreateTimerDelay(tmKey, iDelay, handleFunc)
	if KE_IsValidTimer(self._tTimerList[tmKey]) then
		assert(not self._tTimerList[tmKey], "该计时器名已被使用: "..tmKey)
	end
	self._tTimerList[tmKey] = KE_SetTimeout(iDelay, handleFunc)
end

function clsCoreObject:CreateTimerLoop(tmKey, iInterval, handleFunc)
	if KE_IsValidTimer(self._tTimerList[tmKey]) then
		assert(not self._tTimerList[tmKey], "该计时器名已被使用: "..tmKey)
	end
	self._tTimerList[tmKey] = KE_SetInterval(iInterval, handleFunc)
end

function clsCoreObject:CreateAbsTimerDelay(tmKey, iDelay, handleFunc)
	if KE_IsValidTimer(self._tTimerList[tmKey]) then
		assert(not self._tTimerList[tmKey], "该计时器名已被使用: "..tmKey)
	end
	self._tTimerList[tmKey] = KE_SetAbsTimeout(iDelay, handleFunc)
end

function clsCoreObject:CreateAbsTimerLoop(tmKey, iInterval, handleFunc)
	if KE_IsValidTimer(self._tTimerList[tmKey]) then
		assert(not self._tTimerList[tmKey], "该计时器名已被使用: "..tmKey)
	end
	self._tTimerList[tmKey] = KE_SetAbsInterval(iInterval, handleFunc)
end

function clsCoreObject:DestroyTimer(tmKey)
	KE_KillTimer(self._tTimerList[tmKey])
	self._tTimerList[tmKey] = nil
end

function clsCoreObject:DestroyAllTimer()
	for tmKey, tm in pairs(self._tTimerList) do
		KE_KillTimer(self._tTimerList[tmKey])
	end
	self._tTimerList = {}
end

function clsCoreObject:PauseTimer(tmKey, bPause)
	if self._tTimerList[tmKey] then
		KE_PauseTimer(self._tTimerList[tmKey], bPause)
	end
end

function clsCoreObject:PauseAllTimer(bPause)
	for tmKey, tm in pairs(self._tTimerList) do
		self:PauseTimer(tmKey, bPause)
	end
end

function clsCoreObject:HasTimer(tmKey)
	if KE_IsValidTimer(self._tTimerList[tmKey]) then
		return true
	else
		self._tTimerList[tmKey] = nil
		return false
	end
end
