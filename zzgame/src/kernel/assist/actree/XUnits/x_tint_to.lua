-------------------------
-- 动画cc.TintTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["r"] = 1,
	["g"] = 222,
	["b"] = 112,
}

local x_tint_to = class("x_tint_to", clsPromise)

x_tint_to._default_args = default_args

function x_tint_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_tint_to"
end

function x_tint_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXTintTo then
		target:GetBody():stopAction(target._tmpXTintTo)
		target._tmpXTintTo = nil
	end
end

function x_tint_to:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	local r = args.r and default_args.r
	local g = args.g and default_args.g
	local b = args.b and default_args.b
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXTintTo = tmpAtom:GetBody():runAction(cc.Sequence:create(
		cc.TintTo:create(seconds, r, g, b), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXTintTo = nil 
			self:Done()
		end)
	))
end

return x_tint_to
