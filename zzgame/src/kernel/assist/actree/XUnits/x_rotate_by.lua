-------------------------
-- 动画cc.RotateBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["Angle"] = 360,
}

local x_rotate_by = class("x_rotate_by", clsPromise)

x_rotate_by._default_args = default_args

function x_rotate_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_rotate_by"
end

function x_rotate_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXRotateBy then
		target:stopAction(target._tmpXRotateBy)
		target._tmpXRotateBy = nil
	end
end

function x_rotate_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	local Angle = args.Angle or default_args.Angle
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXRotateBy = tmpAtom:runAction(cc.Sequence:create(
		cc.RotateBy:create(seconds, Angle), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXRotateBy = nil
			self:Done()
		end)
	))
end

return x_rotate_by
