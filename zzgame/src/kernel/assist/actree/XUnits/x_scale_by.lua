-------------------------
-- 动画cc.ScaleBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["scaleX"] = 2,
	["scaleY"] = 2,
	["seconds"] = 1,
}

local x_scale_by = class("x_scale_by", clsPromise)

x_scale_by._default_args = default_args

function x_scale_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_scale_by"
end

function x_scale_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXScaleBy then
		target:stopAction(target._tmpXScaleBy)
		target._tmpXScaleBy = nil
	end
end

function x_scale_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local scaleX = args.scaleX
	local scaleY = args.scaleY
	local seconds = args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXScaleBy = tmpAtom:runAction(cc.Sequence:create(
		cc.ScaleBy:create(seconds, scaleX, scaleY), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXScaleBy = nil
			self:Done()
		end)
	))
end

return x_scale_by
