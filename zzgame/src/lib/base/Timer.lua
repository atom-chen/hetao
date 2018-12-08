-------------------------
-- 计时器
-------------------------
local clsTimerBase = class("clsTimerBase")

function clsTimerBase:ctor(iID, iInterval, func, bTickOnce)
	self._Uid = iID
	self._iInterval = iInterval
	self._passedTime = 0
	self._bPause = false
	self._bStoped = false
	self._bTickOnce = bTickOnce
	self._func = func
end

function clsTimerBase:dtor()
	self._bStoped = true
	self._func = nil
end

function clsTimerBase:Pause(bPause)
	if bPause == nil then bPause = true end
	self._bPause = bPause
end

function clsTimerBase:Stop()
	self._bStoped = true
	self._func = nil
end

---------------------------------------------

-- 基于帧
local clsTimer = class("clsTimer", clsTimerBase)

function clsTimer:ctor(iID, iInterval, func, bTickOnce)
	clsTimerBase.ctor(self, iID, iInterval, func, bTickOnce)
end

function clsTimer:TickPerFrame(deltaTime)
	if self._bStoped then 
		self._func = nil
		return true 
	end
	
	if self._bPause then return end
	
	self._passedTime = self._passedTime + 1
	
	if self._passedTime >= self._iInterval then
		self._passedTime = 0
		
		if self._bTickOnce then
			self._bStoped = true
			self._func(deltaTime)
			self._func = nil
			return true
		else
			return self._func(deltaTime)
		end
	end
end


-- 基于秒
local clsAbsTimer = class("clsAbsTimer", clsTimerBase)

function clsAbsTimer:ctor(iID, iInterval, func, bTickOnce)
	clsTimerBase.ctor(self, iID, iInterval, func, bTickOnce)
end

function clsAbsTimer:TickPerFrame(deltaTime)
	if self._bStoped then 
		self._func = nil
		return true 
	end
	
	if self._bPause then return end
	
	self._passedTime = self._passedTime + deltaTime
	
	if self._passedTime >= self._iInterval then
		self._passedTime = self._passedTime - self._iInterval
		
		if self._bTickOnce then
			self._bStoped = true
			self._func(deltaTime)
			self._func = nil
			return true
		else
			return self._func(deltaTime)
		end
	end
end

--------------------------分割线--------------------------

local _gTimerID = 0

ClsTimerManager = class("ClsTimerManager")
ClsTimerManager.__is_singleton = true

function ClsTimerManager:ctor()
	self._isUpdating = false
	self._tAllTimerById = {}
end

function ClsTimerManager:dtor()
	self._isUpdating = true
	self._tAllTimerById = nil
end

--@每帧更新
function ClsTimerManager:FrameUpdate(deltaTime)
	---begin tick-----------------
	self._isUpdating = true 
	
	local needDels = {}
	local timer_list = self._tAllTimerById
	for _, Tmr in pairs(timer_list) do
		if Tmr:TickPerFrame(deltaTime) then
			needDels[#needDels+1] = Tmr._Uid
		end
	end
	for _, tmDel in ipairs(needDels) do
		self:_del_timer_(tmDel)
	end
	needDels = nil
	
	self._isUpdating = false 
	---end tick-----------------
end

function ClsTimerManager:_has_timer(func)
	local timer_list = self._tAllTimerById
	for _, Tmr in pairs(timer_list) do
		if Tmr._func == func then
			return true
		end
	end
	return false 
end

function ClsTimerManager:_add_timer_(tmID, Tmr)
	assert(not self:_has_timer(Tmr._func), "【错误】重复添加相同计时器")
	assert(not self._tAllTimerById[tmID])
	self._tAllTimerById[tmID] = Tmr 
end

function ClsTimerManager:_del_timer_(tmID)
	if self._tAllTimerById[tmID] then
		KE_SafeDelete(self._tAllTimerById[tmID])
		self._tAllTimerById[tmID] = nil
	end
end	

-- 创建计时器（基于帧）
function ClsTimerManager:CreateTimer(iInterval, func, bTickOnce)
	assert(iInterval>=0 and is_function(func))
	_gTimerID = _gTimerID + 1
	
	local Tmr = clsTimer.new(_gTimerID, iInterval, func, bTickOnce)
	self:_add_timer_(_gTimerID, Tmr)

	return _gTimerID
end

-- 创建计时器（基于时间）
function ClsTimerManager:CreateAbsTimer(iInterval, func, bTickOnce)
	assert(iInterval>=0 and is_function(func))
	_gTimerID = _gTimerID + 1
	
	local Tmr = clsAbsTimer.new(_gTimerID, iInterval, func, bTickOnce)
	self:_add_timer_(_gTimerID, Tmr)

	return _gTimerID
end

-- 销毁计时器
function ClsTimerManager:KillTimer(tmID)
	if (tmID == nil) or (not self._tAllTimerById[tmID]) then return end
	self._tAllTimerById[tmID]:Stop()
	self:_del_timer_(tmID)
end

-- 暂停计时器
function ClsTimerManager:PauseTimer(tmID, bPause)
	if tmID == nil then return end
	if self._tAllTimerById[tmID] then
		self._tAllTimerById[tmID]:Pause(bPause)
	end
end

function ClsTimerManager:DumpDebugInfo()
	local cnt = 0
	for tmID, Tmr in pairs(self._tAllTimerById) do
		cnt = cnt + 1
		print( cnt, tmID, Tmr._iInterval )
	end
end

-----------------------分割线------------------------------------

local tmrInstance = ClsTimerManager.GetInstance()

KE_SetInterval = function(iInterval, func) 
	return tmrInstance:CreateTimer(iInterval, func) 
end

KE_SetTimeout = function(iDelay, func) 
	return tmrInstance:CreateTimer(iDelay, func, true) 
end

KE_SetAbsInterval = function(iInterval, func) 
	return tmrInstance:CreateAbsTimer(iInterval, func) 
end

KE_SetAbsTimeout = function(iDelay, func) 
	return tmrInstance:CreateAbsTimer(iDelay, func, true) 
end

KE_KillTimer = function(tmID)
	if not tmID then return end
	tmrInstance:KillTimer(tmID)
end

KE_PauseTimer = function(tmID, bPause)
	if not tmID then return end
	assert(is_boolean(bPause))
	tmrInstance:PauseTimer(tmID, bPause)
end

KE_IsValidTimer = function(tmID)
	if tmID == nil then return false end
	if tmrInstance._tAllTimerById[tmID] then return true end
	return false
end
