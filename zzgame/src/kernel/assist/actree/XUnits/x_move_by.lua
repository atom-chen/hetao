-------------------------
-- 动画cc.MoveBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["stepx"] = 0,
	["stepy"] = 0,
	["seconds"] = 2,
}

local x_move_by = class("x_move_by", clsPromise)

x_move_by._default_args = default_args

function x_move_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_move_by"
end

function x_move_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXMoveBy then
		target:stopAction(target._tmpXMoveBy)
		target._tmpXMoveBy = nil
	end
end

function x_move_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local stepx = args.stepx
	local stepy = args.stepy
	local seconds = args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXMoveBy = tmpAtom:runAction(cc.Sequence:create(
		cc.MoveBy:create(seconds, cc.p(stepx, stepy)), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXMoveBy = nil
			self:Done()
		end)
	))
end

return x_move_by
