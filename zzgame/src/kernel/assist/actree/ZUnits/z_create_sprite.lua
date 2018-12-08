-------------------------
-- 创建精灵
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["parent_atom"] = 0,
	["respath"] = "res/effects/effect_img/huoqiu.png",
	["x"] = 500,
	["y"] = 400,
}

local z_create_sprite = class("z_create_sprite", clsPromise)

z_create_sprite._default_args = default_args

function z_create_sprite:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "z_create_sprite"
end

function z_create_sprite:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id
	local respath = args.respath or default_args.respath
	local x = args.x or default_args.x
	local y = args.y or default_args.y
	
	xCtx:CreateXSprite(atom_id, respath)
	
	local sprBullet = xCtx:GetAtom(atom_id)
	if not sprBullet then
		logger.error("====ERROR: 创建精灵失败", atom_id, self._node_type, respath)
		return self:Done()
	end
	
	xCtx:GetAtom(args.parent_atom):addChild(sprBullet)
	sprBullet:setPosition(x,y)
	self:Done()
end

return z_create_sprite
