-------------------------
-- 动画cc.CallBack
-------------------------
module("smartor",package.seeall)

local default_args = {
	["func"] = function()  end,
}

local x_callfunc = class("x_callfunc", clsPromise)

x_callfunc._default_args = default_args

function x_callfunc:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_callfunc"
	assert(type(argInfo.func)=="function")
end

function x_callfunc:Proc(args, xCtx)
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	args.func()
	self:Done()
end

return x_callfunc
