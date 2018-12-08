-------------------------
-- 动画setOpacity
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["alpha"] = 255,
}

local x_set_opacity = class("x_set_opacity", clsPromise)

x_set_opacity._default_args = default_args

function x_set_opacity:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_set_opacity"
end

function x_set_opacity:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local alpha = args.alpha or default_args.alpha
	
	local tmpChar = xCtx:GetAtom(atom_id)
	if not tmpChar then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpChar:setOpacity(alpha)
	self:Done()
end

return x_set_opacity
