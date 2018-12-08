-------------------------
-- 播放命令
-------------------------
module("smartor",package.seeall)

local CMDDIR = "kernel.assist.actree"
local CMD_TABLE = {}

function NewUnit(sCmdName, argInfo, Ctx)
	return CMD_TABLE[sCmdName].new(argInfo, Ctx)
end

local function _register_command(sCmdName, cls)
	assert(sCmdName == cls.__cname)
	assert(not CMD_TABLE[sCmdName], string.format("已经注册过该命令：%s",sCmdName))
	CMD_TABLE[sCmdName] = cls
end
local function RegisterXCommand(sCmdName)
	local cls_name = sCmdName
	local filePath = string.format("%s.XUnits.%s", CMDDIR, cls_name)
	local cls = require(filePath)
	_register_command(sCmdName, cls)
end
local function RegisterZCommand(sCmdName)
	local cls_name = sCmdName
	local filePath = string.format("%s.ZUnits.%s", CMDDIR, cls_name)
	local cls = require(filePath)
	_register_command(sCmdName, cls)
end
local function RegisterLCommand(sCmdName)
	local cls_name = sCmdName
	local filePath = string.format("%s.LogicUnits.%s", CMDDIR, cls_name)
	local cls = require(filePath)
	_register_command(sCmdName, cls)
end

local function RegisterAll()
	---
	RegisterXCommand("x_root_node")
	RegisterXCommand("x_callfunc")
	RegisterXCommand("x_delay_time")
	RegisterXCommand("x_delay_frame")
	RegisterXCommand("x_move_to")
	RegisterXCommand("x_move_by")
	RegisterXCommand("x_scale_to")
	RegisterXCommand("x_scale_by")
	RegisterXCommand("x_rotate_to")
	RegisterXCommand("x_rotate_by")
	RegisterXCommand("x_skew_to")
	RegisterXCommand("x_skew_by")
	RegisterXCommand("x_jump_to")
	RegisterXCommand("x_jump_by")
	RegisterXCommand("x_fade_in")
	RegisterXCommand("x_fade_out")
	RegisterXCommand("x_tint_to")
	RegisterXCommand("x_tint_by")
	RegisterXCommand("x_cardinal_spline_by")
	RegisterXCommand("x_blink")
	RegisterXCommand("x_set_opacity")
	RegisterXCommand("x_show_obj")
--	RegisterXCommand("x_cardinal_spline")
--	RegisterXCommand("x_catmull_rom")
--	RegisterXCommand("x_bezier_to")
--	RegisterXCommand("x_bezier_by")
--	RegisterXCommand("x_seq_animation")
--	RegisterXCommand("x_orbit_camera")
--	RegisterXCommand("x_follow")
--	RegisterXCommand("x_targeted")
--	RegisterXCommand("x_pause_all_act")
--	RegisterXCommand("x_resume_all_act")
	---
	RegisterZCommand("z_create_effect")
	RegisterZCommand("z_create_panel")
	RegisterZCommand("z_create_sprite")
	RegisterZCommand("z_destroy_effect")
	RegisterZCommand("z_destroy_panel")
	RegisterZCommand("z_destroy_sprite")
end

----------------------------------------------------------------

RegisterAll()
