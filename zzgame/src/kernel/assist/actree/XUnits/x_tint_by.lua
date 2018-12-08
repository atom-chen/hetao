-------------------------
-- 动画cc.TintBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["deltaR"] = 1,
	["deltaG"] = 222,
	["deltaB"] = 112,
}

local x_tint_by = class("x_tint_by", clsPromise)

x_tint_by._default_args = default_args

function x_tint_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_tint_by"
end

function x_tint_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXTintBy then
		target:GetBody():stopAction(target._tmpXTintBy)
		target._tmpXTintBy = nil
	end
end

function x_tint_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	local deltaR = args.deltaR and default_args.deltaR
	local deltaG = args.deltaG and default_args.deltaG
	local deltaB = args.deltaB and default_args.deltaB
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXTintBy = tmpAtom:GetBody():runAction(cc.Sequence:create(
		cc.TintBy:create(seconds, deltaR, deltaG, deltaB), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXTintBy = nil 
			self:Done()
		end)
	))
end

return x_tint_by
