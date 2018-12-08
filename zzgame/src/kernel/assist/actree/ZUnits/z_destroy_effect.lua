-------------------------
-- 销毁特效
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
}

local z_destroy_effect = class("z_destroy_effect", clsPromise)

z_destroy_effect._default_args = default_args

function z_destroy_effect:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "z_destroy_effect"
end

function z_destroy_effect:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	
	if not xCtx:GetAtom(atom_id) then 
		logger.error("====ERROR: 要删除的特效不存在：", atom_id, self._node_type) 
	end
	xCtx:DestroyAtom(atom_id)
	
	self:Done()
end

return z_destroy_effect
