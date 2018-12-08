-------------------------
-- 动画cc.MoveTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["sx"] = 0,
	["sy"] = 0,
	["dx"] = 0,
	["dy"] = 0,
	["seconds"] = 2,
}

local x_move_to = class("x_move_to", clsPromise)

x_move_to._default_args = default_args

function x_move_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_move_to"
end

function x_move_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXMoveTo then
		target:stopAction(target._tmpXMoveTo)
		target._tmpXMoveTo = nil
	end
end

function x_move_to:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local sx = args.sx
	local sy = args.sy
	local dx = args.dx
	local dy = args.dy
	local seconds = args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	if sx and sy then tmpAtom:setPosition(sx, sy) end
	
	tmpAtom._tmpXMoveTo = tmpAtom:runAction(cc.Sequence:create(
		cc.MoveTo:create(seconds, cc.p(dx, dy)), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXMoveTo = nil
			self:Done()
		end)
	))
end

return x_move_to
