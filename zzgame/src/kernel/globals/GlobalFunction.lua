-------------------------
-- 全局函数
-------------------------
function KE_GC_LUA()
	print("------------清理Lua内存开始------------")
	print( string.format("LUA内存：%fM", collectgarbage("count")/1000) )
	collectgarbage("collect")
	collectgarbage("collect")
	print( string.format("LUA内存：%fM", collectgarbage("count")/1000) )
	print("------------清理Lua内存结束------------")
end

function KE_GC_ENGINE()
	print("------------清理引擎内存开始-----------")
	ClsResManager.GetInstance():ClearEngineCaches()
	print("------------清理引擎内存结束-----------")
end

function KE_IsEditMode()
	return GAME_CONFIG.APP_MODE ~= 1
end

------------------------
-- 脚本层创建的对象分为以下三类
-- 1. 纯引擎对象：如 local spr = cc.Sprite:create()
-- 2. 纯脚本对象：class及其子类等，如 local g_EventMgr = clsEventSource:new()
-- 3. 同时继承了脚本对象和引擎对象的对象：local wnd = clsWindow.new()
-- 所有对象的销毁使用统一接口 KE_SafeDelete
------------------------
local tolua_isnull = tolua.isnull

function KE_IsNullCobj(obj)
	return tolua_isnull(obj)
end

function KE_SetParent(childObj, parentObj, order)
	if childObj:getParent() == parentObj then return end
	if parentObj == nil then
		KE_RemoveFromParent(childObj)
		assert(false, "为了方便搜索，请使用KE_RemoveFromParent")
		return
	end
	childObj:removeFromParent(false)
	if order then
		parentObj:addChild(childObj, order)
	else
		parentObj:addChild(childObj)
	end
end

function KE_RemoveFromParent(childObj)
	if childObj then 
		if tolua_isnull(childObj) then logger.error("del obj many times") return end
		childObj:removeFromParent()
	end
end

-- 删除对象的统一接口
function KE_SafeDelete(obj)
	if obj then
		if obj.removeFromParent then
			if not tolua_isnull(obj) then
				obj:removeFromParent()
			end
		elseif obj.delete then
			obj:delete()
		end
	end
end

-- 
function KE_ExtendClass(WhichClass)
	if WhichClass.HasScriptHandler then 
		assert(WhichClass.HasScriptHandler)
		assert(WhichClass.AddScriptHandler)
		assert(WhichClass.DelScriptHandler)
		assert(WhichClass.EnableNodeEvents)
		assert(WhichClass.DisableNodeEvents)
		return
	else 
		assert(not WhichClass.HasScriptHandler)
		assert(not WhichClass.AddScriptHandler)
		assert(not WhichClass.DelScriptHandler)
		assert(not WhichClass.EnableNodeEvents)
		assert(not WhichClass.DisableNodeEvents)
	end
	
	function WhichClass:HasScriptHandler(func)
		if self._t_script_handlers then
			for evtName, handlerList in pairs(self._t_script_handlers) do
				for _, f in ipairs(handlerList) do 
					if f == func then
						return true 
					end
				end
			end
		end
		return false 
	end
	
	function WhichClass:AddScriptHandler(evtName, func)
		self:EnableNodeEvents()
		assert(type(evtName)=="string")
		assert(type(func)=="function")
		if self:HasScriptHandler(func) then return end
		self._t_script_handlers = self._t_script_handlers or {}
		self._t_script_handlers[evtName] = self._t_script_handlers[evtName] or {}
		table.insert(self._t_script_handlers[evtName], func)
		return func
	end
	
	function WhichClass:DelScriptHandler(func)
		if self._t_script_handlers then
			for evtName, handlerList in pairs(self._t_script_handlers) do
				for i, f in ipairs(handlerList) do 
					if f == func then
						table.remove(self._t_script_handlers[evtName], i)
						return
					end
				end
			end
		end
	end
	
	function WhichClass:EnableNodeEvents()
	    if self._bIsNodeEventEnabled then return end
		self._bIsNodeEventEnabled = true
		self:registerScriptHandler(function(evtName)
			if self._t_script_handlers and self._t_script_handlers[evtName] then
				local handlerList = self._t_script_handlers[evtName]
				for _, func in ipairs(handlerList) do 
					func()
				end 
			end 
			
			if evtName == "cleanup" then 
				g_EventMgr:DelListener(self)
				g_EventMgr:DelListener(self.__cname)
				if self.delete then self:delete() end --调用脚本层析构
				self._t_script_handlers = nil
			elseif evtName == "enter" then
				if self.onEnter then
					self:onEnter()
				end
			elseif evtName == "exit" then
				if self.onExit then
					self:onExit()
				end
			end
		end)
	end
	
	function WhichClass:DisableNodeEvents()
		if not self._bIsNodeEventEnabled then return end
	    self:unregisterScriptHandler()
	    self._bIsNodeEventEnabled = false
	end
end

-- call by engine 
function networkStateChange(sState)
	if not PlatformHelper or not PlatformHelper.isNetworkConnected then return end
	
	local bConnected = PlatformHelper.isNetworkConnected()
	
	if ClsUIManager then
		if not bConnected then
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_NET_STATE", "", "网络连接异常，请检查网络状况", nil, nil, nil, 2)
		else
			ClsUIManager.GetInstance():CloseConfirmDlg("CFM_NET_STATE")
		end
	end
	
	if g_EventMgr then 
		g_EventMgr:FireEvent("NET_STATE_CHANGE", bConnected)
	end
end

function KE_CheckNetConnect(bForce)
	if not PlatformHelper or not PlatformHelper.isNetworkConnected then return true end
	
	local bConnected = PlatformHelper.isNetworkConnected()
	
	if bForce then
		if ClsUIManager then
			if not bConnected then
				ClsUIManager.GetInstance():PopConfirmDlg("CFM_NET_STATE", "", "网络连接异常，请检查网络状况", nil, nil, nil, 2)
			else
				ClsUIManager.GetInstance():CloseConfirmDlg("CFM_NET_STATE")
			end
		end
	else
		if not bConnected then
			if utils and utils.TellMe then
				utils.TellMe("请检查网络连接是否正常")
			end
		end
	end
	
	return bConnected
end
