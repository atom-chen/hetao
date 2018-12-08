-------------------------
-- 销毁面板
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
}

local z_destroy_sprite = class("z_destroy_sprite", clsPromise)

z_destroy_sprite._default_args = default_args

function z_destroy_sprite:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "z_destroy_sprite"
end

function z_destroy_sprite:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	
	if not xCtx:GetAtom(atom_id) then 
		logger.error("====ERROR: 要删除的精灵不存在：", atom_id, self._node_type) 
	end
	xCtx:DestroyAtom(atom_id)
	self:Done()
end

return z_destroy_sprite
