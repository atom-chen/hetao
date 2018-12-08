-------------------------
-- 创建特效
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["effect_id"] = 1,
	["res_path"] = "res/effects/effect_seq/bingpo.plist",
	["x"] = 0,
	["y"] = 0,
}

local z_create_effect = class("z_create_effect", clsPromise)

z_create_effect._default_args = default_args

function z_create_effect:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "z_create_effect"
end

function z_create_effect:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local res_path = args.res_path or default_args.res_path
	local x = args.x or default_args.x
	local y = args.y or default_args.y
	
	xCtx:CreateXEffect(atom_id, res_path)
	
	local tmpEffect = xCtx:GetAtom(atom_id)
	if not tmpEffect then
		logger.error("====ERROR: 创建特效失败", atom_id, self._node_type)
		return self:Done()
	end
	
	if VVDirector:GetMap() then
		VVDirector:GetMap():AddObject(tmpEffect, x, y)
	end
	
	self:Done()
end

return z_create_effect
