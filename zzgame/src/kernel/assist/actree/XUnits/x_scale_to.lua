-------------------------
-- 动画cc.ScaleTo
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["scaleX"] = 1,
	["scaleY"] = 2,
	["seconds"] = 1,
}

local x_scale_to = class("x_scale_to", clsPromise)

x_scale_to._default_args = default_args

function x_scale_to:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_scale_to"
end

function x_scale_to:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXScaleTo then
		target:stopAction(target._tmpXScaleTo)
		target._tmpXScaleTo = nil
	end
end

function x_scale_to:OnProc()
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
	
	tmpAtom._tmpXScaleTo = tmpAtom:runAction(cc.Sequence:create(
		cc.ScaleTo:create(seconds, scaleX, scaleY), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXScaleTo = nil 
			self:Done()
		end)
	))
end

return x_scale_to
