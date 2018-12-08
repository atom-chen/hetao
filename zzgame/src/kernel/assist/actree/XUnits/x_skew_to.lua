-------------------------
-- 动画cc.SkewTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["SkewX"] = 40,
	["SkewY"] = -40,
	["seconds"] = 1,
}

local x_skew_to = class("x_skew_to", clsPromise)

x_skew_to._default_args = default_args

function x_skew_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_skew_to"
end

function x_skew_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXSkewTo then
		target:stopAction(target._tmpXSkewTo)
		target._tmpXSkewTo = nil
	end
end

function x_skew_to:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local SkewX = args.SkewX
	local SkewY = args.SkewY
	local seconds = args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXSkewTo = tmpAtom:runAction(cc.Sequence:create(
		cc.SkewTo:create(seconds, SkewX, SkewY), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXSkewTo = nil 
			self:Done()
		end)
	))
end

return x_skew_to
