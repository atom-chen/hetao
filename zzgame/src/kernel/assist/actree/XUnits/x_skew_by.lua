-------------------------
-- 动画cc.SkewBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["deltaSkewX"] = 40,
	["deltaSkewY"] = -40,
	["seconds"] = 1,
}

local x_skew_by = class("x_skew_by", clsPromise)

x_skew_by._default_args = default_args

function x_skew_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_skew_by"
end

function x_skew_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXSkewBy then
		target:stopAction(target._tmpXSkewBy)
		target._tmpXSkewBy = nil
	end
end

function x_skew_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local deltaSkewX = args.deltaSkewX
	local deltaSkewY = args.deltaSkewY
	local seconds = args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXSkewBy = tmpAtom:runAction(cc.Sequence:create(
		cc.SkewBy:create(seconds, deltaSkewX, deltaSkewY), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXSkewBy = nil 
			self:Done()
		end)
	))
end

return x_skew_by
