-------------------------
-- 脚本录制
-------------------------
ClsTestManager = class("ClsTestManager")
ClsTestManager.__is_singleton = true

function ClsTestManager:ctor()
	self._b_testing = false
	self._cmd_list = {}
end

function ClsTestManager:dtor()
    
end

function ClsTestManager:AddCommand(cmdName, args)
	if not GAME_CONFIG.VV_ENABLE_AUTO_TEST then return end 
	if self._b_testing then return end
	self._cmd_list[#self._cmd_list+1] = { cmdName, args }
end

function ClsTestManager:RunRecords()
	--[[
	if not GAME_CONFIG.VV_ENABLE_AUTO_TEST then return end
	if self._b_testing then return end
	logger.warn("开始测试")
	self._b_testing = true
	local n = 0
	KE_SetAbsInterval(0.2, function()
		n = n + 1
		if not self._cmd_list[n] then 
			self._b_testing = false
			logger.warn("完成测试")
			self._cmd_list = {}
			return true	
		end
		
		if self._cmd_list[n][1] == "cmd_touch_begin" then
			local x,y = unpack(self._cmd_list[n][2])
			if x and y then
				xianyou.SimulateMgr:getInstance():simuTouchBegin(x, y)
			end
		elseif self._cmd_list[n][1] == "cmd_touch_move" then
			local x,y = unpack(self._cmd_list[n][2])
			if x and y then
				xianyou.SimulateMgr:getInstance():simuTouchMove(x, y)
			end
		elseif self._cmd_list[n][1] == "cmd_touch_end" then
			local x,y = unpack(self._cmd_list[n][2])
			if x and y then
				xianyou.SimulateMgr:getInstance():simuTouchEnd(x, y)
			end
		end
	end)
	]]
end
