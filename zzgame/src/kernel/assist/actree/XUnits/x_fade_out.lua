-------------------------
-- 动画cc.FadeOut
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["seconds"] = 1,
}

local x_fade_out = class("x_fade_out", clsPromise)

x_fade_out._default_args = default_args

function x_fade_out:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_fade_out"
end

function x_fade_out:OnStop()
	local atom_id = self:GetArgInfo().atom_id
	local target = self:GetContext():GetAtom(atom_id)
	if target and target._tmpXFadeOut then
		target:GetBody():stopAction(target._tmpXFadeOut)
		target._tmpXFadeOut = nil
	end
end

function x_fade_out:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local seconds = args.seconds or default_args.seconds
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom._tmpXFadeOut = tmpAtom:GetBody():runAction(cc.Sequence:create(
		cc.FadeOut:create(seconds), 
		cc.CallFunc:create(function()
			tmpAtom._tmpXFadeOut = nil 
			self:Done()
		end)
	))
end

return x_fade_out
