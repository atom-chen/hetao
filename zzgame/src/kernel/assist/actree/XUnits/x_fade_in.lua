-------------------------
-- 动画cc.FadeIn
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
}

local x_fade_in = class("x_fade_in", clsPromise)

x_fade_in._default_args = default_args

function x_fade_in:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_fade_in"
end

function x_fade_in:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXFadeIn then
		target:GetBody():stopAction(target._tmpXFadeIn)
		target._tmpXFadeIn = nil
	end
end

function x_fade_in:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXFadeIn = tmpAtom:GetBody():runAction(cc.Sequence:create(
		cc.FadeIn:create(seconds), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXFadeIn = nil
			self:Done()
		end)
	))
end

return x_fade_in
