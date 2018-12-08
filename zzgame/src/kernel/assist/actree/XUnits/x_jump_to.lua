-------------------------
-- 动画cc.JumpTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["dstX"] = 40,
	["dstY"] = 40,
	["jmpHeight"] = 100,
	["jmpTimes"] = 1,
}

local x_jump_to = class("x_jump_to", clsPromise)

x_jump_to._default_args = default_args

function x_jump_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_jump_to"
end

function x_jump_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXJumpTo then
		target:stopAction(target._tmpXJumpTo)
		target._tmpXJumpTo = nil
	end
end

function x_jump_to:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local seconds = args.seconds or default_args.seconds
	local dstX = args.dstX or default_args.dstX
	local dstY = args.dstY or default_args.dstY
	local jmpHeight = args.jmpHeight or default_args.jmpHeight
	local jmpTimes = args.jmpTimes or default_args.jmpTimes
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXJumpTo = tmpAtom:runAction(cc.Sequence:create(
		cc.JumpTo:create(seconds, cc.p(dstX,dstY), jmpHeight, jmpTimes), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXJumpTo = nil
			self:Done()
		end)
	))
end

return x_jump_to
