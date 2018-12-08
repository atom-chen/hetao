-------------------------
-- 动画cc.DelayTime
-------------------------
module("smartor",package.seeall)

local default_args = {
	["seconds"] = 1,
}

local x_delay_time = class("x_delay_time", clsPromise)

x_delay_time._default_args = default_args

function x_delay_time:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_delay_time"
end

function x_delay_time:OnStop()
    KE_KillTimer(self._timer)
    self._timer = nil
end

function x_delay_time:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local seconds = args.seconds
	self._timer = KE_SetAbsTimeout(seconds, function()
		self._timer = nil
		self:Done()
	end)
end

return x_delay_time
