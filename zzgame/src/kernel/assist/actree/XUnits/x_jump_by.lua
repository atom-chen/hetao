-------------------------
-- 动画cc.JumpBy
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["deltaX"] = 40,
	["deltaY"] = 40,
	["jmpHeight"] = 200,
	["jmpTimes"] = 1,
}

local x_jump_by = class("x_jump_by", clsPromise)

x_jump_by._default_args = default_args

function x_jump_by:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_jump_by"
end

function x_jump_by:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXJumpBy then
		target:stopAction(target._tmpXJumpBy)
		target._tmpXJumpBy = nil
	end
end

function x_jump_by:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local seconds = args.seconds or default_args.seconds
	local deltaX = args.deltaX or default_args.deltaX
	local deltaY = args.deltaY or default_args.deltaY
	local jmpHeight = args.jmpHeight or default_args.jmpHeight
	local jmpTimes = args.jmpTimes or default_args.jmpTimes
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXJumpBy = tmpAtom:runAction(cc.Sequence:create(
		cc.JumpBy:create(seconds, cc.p(deltaX,deltaY), jmpHeight, jmpTimes), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXJumpBy = nil 
			self:Done()
		end)
	))
end

return x_jump_by
