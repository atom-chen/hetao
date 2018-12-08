-------------------------
-- 动画cc.DelayTime
-------------------------
module("smartor",package.seeall)

local default_args = {
	["frames"] = 1,
}

local x_delay_frame = class("x_delay_frame", clsPromise)

x_delay_frame._default_args = default_args

function x_delay_frame:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_delay_frame"
end

function x_delay_frame:OnStop()
    KE_KillTimer(self._timer)
    self._timer = nil
end

function x_delay_frame:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local frames = args.frames
	self._timer = KE_SetTimeout(frames, function()
		self._timer = nil
		self:Done()
	end)
end

return x_delay_frame
