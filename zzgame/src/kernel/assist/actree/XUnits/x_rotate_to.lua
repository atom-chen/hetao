-------------------------
-- 动画cc.RotateTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
	["toAngle"] = 0,
}

local x_rotate_to = class("x_rotate_to", clsPromise)

x_rotate_to._default_args = default_args

function x_rotate_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_rotate_to"
end

function x_rotate_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXRotateTo then
		target:stopAction(target._tmpXRotateTo)
		target._tmpXRotateTo = nil
	end
end

function x_rotate_to:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	local toAngle = args.toAngle or default_args.toAngle
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXRotateTo = tmpAtom:runAction(cc.Sequence:create(
		cc.RotateTo:create(seconds, toAngle), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXRotateTo = nil 
			self:Done()
		end)
	))
end

return x_rotate_to
