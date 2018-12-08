-------------------------
-- 动画cc.Blink
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["times"] = 20,
}

local x_blink = class("x_blink", clsPromise)

x_blink._default_args = default_args

function x_blink:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_blink"
end

function x_blink:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXBlink then
		target:stopAction(target._tmpXBlink)
		target._tmpXBlink = nil
	end
end

function x_blink:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	local times = args.times and default_args.times
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXBlink = tmpAtom:runAction(cc.Sequence:create(
		cc.Blink:create(seconds, times), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXBlink = nil
			self:Done()
		end)
	))
end

return x_blink
