-------------------------
-- 创建面板
-------------------------
module("smartor",package.seeall)

local default_args = {
	["atom_id"] = 1,
	["panel_clsname"] = "clsBenefitUI",
	["x"] = 500,
	["y"] = 400,
}

local z_create_panel = class("z_create_panel", clsPromise)

z_create_panel._default_args = default_args

function z_create_panel:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "z_create_panel"
end

function z_create_panel:OnProc()
	local args = self:GetArgInfo()
	local xCtx = self:GetContext()
	local atom_id = args.atom_id or default_args.atom_id
	local res_path = args.res_path or default_args.res_path
	local x = args.x or default_args.x
	local y = args.y or default_args.y
	
	xCtx:CreateXPanel(atom_id, res_path)
	
	local tmpPanel = xCtx:GetAtom(atom_id)
	if not tmpPanel then
		logger.error("====ERROR: 创建面板失败", atom_id, self._node_type)
		return self:Done()
	end
	
	tmpPanel:setPosition(x,y)
	self:Done()
end

return z_create_panel
