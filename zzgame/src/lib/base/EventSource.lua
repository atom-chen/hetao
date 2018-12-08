-------------------------
-- 事件
-------------------------
local EVENT_ID = 0
local function AllocEventId()
	EVENT_ID = EVENT_ID + 1
	return EVENT_ID
end

clsEventSource = class("clsEventSource")

function clsEventSource:RegisterEventType(evtName)
	assert(type(evtName)=="string" or type(evtName)=="number", "事件名必须为数字或字符串")
	self._tAllEventType = self._tAllEventType or {}
    if self._tAllEventType[evtName] then
	    print(string.format("警告：重复注册相同类型事件: %s",evtName))
    end
	self._tAllEventType[evtName] = true
end

function clsEventSource:ctor()
	self._isFireing = false			-- 是否正在fire事件
	self._tAllEventByName = {}
	self._tAllEventByKey = new_weak_table("k")
end

function clsEventSource:dtor()
	self:ClearAllEvents()
	self._tAllEventByName = nil
	self._tAllEventByKey = nil
end

function clsEventSource:IsEventExist(evtName, handle_func, thisObj)
	local listener_list = self._tAllEventByName[evtName]
	if listener_list then
		for EventId, EventObj in pairs(listener_list) do
			if EventObj[2] == handle_func and EventObj[5] == thisObj then
				return true 
			end
		end
	end 
	return false
end


--触发事件
function clsEventSource:FireEvent(evtName, ...)
	assert(self._tAllEventType[evtName], string.format("未定义事件类型: %s",evtName))
	local listener_list = self._tAllEventByName[evtName]
	if not listener_list then return end
	--------------------
	-- begin fire 
	self._isFireing = true
	for _, EventObj in pairs(listener_list) do 
		EventObj[2](EventObj[5], ...)
	end
	self._isFireing = false
	-- end fire
	--------------------
end

--描述：监听事件的接口
--EventKey: 主要是方便注销事件时，可以通过EventKey来方便批量注销事件
--evtName：要监听的事件名
--handle_func: 事件触发时的回调
--thisObj: handle_func的self对象
--bForceCall: 为true时，会在调用该方法时调用一次handle_func，但注意这时候的调用是没有传递参数的
function clsEventSource:AddListener(EventKey, evtName, handle_func, thisObj, bForceCall)
	assert(EventKey~=nil)
	assert(self._tAllEventType[evtName], string.format("未定义事件类型: %s",evtName))
	assert(type(handle_func)=="function", "回调函数错误")
	
	if self:IsEventExist(evtName, handle_func, thisObj) then
		assert( false, string.format("【Error:】event is already exist") )
		return 
	end
	
	local EventId = AllocEventId()
	local EventObj = { evtName, handle_func, EventId, EventKey, thisObj }
	
	if GAME_CONFIG.VV_DEBUG_EVENT_SOURCE then
		local Info = debug.getinfo(2)
		EventObj[6] = Info.short_src .. Info.currentline
	end
	
	self._tAllEventByName[evtName] = self._tAllEventByName[evtName] or {}
	self._tAllEventByName[evtName][EventId] = EventObj
	
	self._tAllEventByKey[EventKey] = self._tAllEventByKey[EventKey] or {}
	self._tAllEventByKey[EventKey][EventId] = EventObj
	
	if bForceCall then handle_func(thisObj) end
end

--根据AddListener时标记的EventKey，移除被标记为EventKey的所有监听器
function clsEventSource:DelListener(EventKey)
	if EventKey == nil then return end
	local infolist = self._tAllEventByKey[EventKey]
	if not infolist then return end
--	logger.normal("DelListener", EventKey, type(EventKey)=="string" and EventKey or EventKey.__cname)
	for EventId, EventObj in pairs(infolist) do 
		self._tAllEventByName[ EventObj[1] ][EventId] = nil
	end
	self._tAllEventByKey[EventKey] = nil
end

--移除所有的监听器 
function clsEventSource:ClearAllEvents()
	self._tAllEventByName = {}
	self._tAllEventByKey = new_weak_table("k")
end

--移除evtName事件下的所有监听器
function clsEventSource:ClearEventByName(evtName)
	local infolist = self._tAllEventByName[evtName]
	if not infolist then return end
	
	self._tAllEventByName[evtName] = nil
	
	for EventId, EventObj in pairs(infolist) do
		local EventKey = EventObj[4]
		if self._tAllEventByKey[EventKey][EventId] then
			self._tAllEventByKey[EventKey][EventId] = nil
			if table.is_empty(self._tAllEventByKey[EventKey]) then
				self._tAllEventByKey[EventKey] = nil 
			end
		end
	end
end




function clsEventSource:DumpDebugInfo()
	logger.normal("--------------", self.__cname)
	for evtName, listener_list in pairs(self._tAllEventByName) do 
		for evtId, EventObj in pairs(listener_list) do 
			logger.printf( "evtName:%s  evtId:%d", evtName, evtId )
		end 
	end 
	logger.normal("--------------, 所有注册的事件类型")
	local sorted = {}
	for evtName, bbb in pairs(self._tAllEventType) do
		sorted[#sorted+1] = evtName
	end
	table.sort(sorted)
	for _, evtName in ipairs(sorted) do
		logger.normal(evtName)
	end
end 
