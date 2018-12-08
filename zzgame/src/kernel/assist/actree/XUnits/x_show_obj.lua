-------------------------
-- 动画setVisible
-------------------------
module("smartor",package.seeall)

local default_args = {
	atom_id = 1,
	bShow = true,
}

local x_show_obj = class("x_show_obj", clsPromise)

x_show_obj._default_args = default_args

function x_show_obj:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_show_obj"
end

function x_show_obj:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id 
	local bShow = args.bShow or true
	
	local tmpAtom = xCtx:GetAtom(atom_id)
	if not tmpAtom then
		logger.error("====ERROR: 不存在该元素", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpAtom:setVisible(bShow)
	self:Done()
end

return x_show_obj
