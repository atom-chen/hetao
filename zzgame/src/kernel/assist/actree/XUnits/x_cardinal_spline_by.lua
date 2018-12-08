-------------------------
-- 动画cc.CardinalSplineBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["tension"] = 0.5,
	["pt_list"] = {
		{x=0, y=0},
		{x=277, y=0},
		{x=277, y=556},
		{x=0, y=222},
		{x=0, y=0},
		{x=222, y=666},
	},
}

local x_cardinal_spline_by = class("x_cardinal_spline_by", clsPromise)

x_cardinal_spline_by._default_args = default_args

function x_cardinal_spline_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_cardinal_spline_by"
end

function x_cardinal_spline_by:OnStop()
	local atom_id = self:GetArgs().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXCardinalSplineBy then
		target:stopAction(target._tmpXCardinalSplineBy)
		target._tmpXCardinalSplineBy = nil
	end
end

function x_cardinal_spline_by:OnProc()
	local args = self._argInfo
	local xCtx = self._context
	local atom_id = args.atom_id
	local seconds = args.seconds or default_args.seconds
	local pt_list = args.pt_list or default_args.pt_list
	local tension = args.tension or default_args.tension
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXCardinalSplineBy = tmpAtom:runAction(cc.Sequence:create(
		cc.CardinalSplineBy:create(seconds, pt_list, tension), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXCardinalSplineBy = nil
			self:Done()
		end)
	))
end

return x_cardinal_spline_by
