-------------------------
-- 常量
-------------------------
module("const", package.seeall)

-- 客户端终端类型
CLIENT_TYPE_ENUM = {
	UNKNOWN_CLIENT_COMPONENT_TYPE = 0,
	CLIENT_TYPE_MOBILE = 1,
	CLIENT_TYPE_WIN = 2,
	CLIENT_TYPE_LINUX = 3,
	CLIENT_TYPE_MAC = 4,
	CLIENT_TYPE_BROWSER = 5,
	CLIENT_TYPE_BOTS = 6,
	CLIENT_TYPE_MINI = 7,
}

FROMWAY = "1"
if device.platform == "android" then
	FROMWAY = "2"
elseif device.platform == "ios" then
	FROMWAY = "1"
end

-- 默认字体
local _DEF_FONT_CFG = {
	fontFilePath = "uistu/fonts/wryh_arial.ttf",
	fontSize = 24,
	outlineSize = 0,
	glyphs = cc.GLYPHCOLLECTION_DYNAMIC,
	customGlyphs = nil,
	distanceFieldEnabled = false,
}
function FONT_CFG(fontSize, outlineSize) 
	local fontcfg = table.clone(_DEF_FONT_CFG) 
	if fontSize then fontcfg.fontSize = fontSize end
	if outlineSize then fontcfg.outlineSize = outlineSize end 
	return fontcfg
end
function DEF_FONT_CFG_REF() 
	return _DEF_FONT_CFG 
end

--层定义
LAYER_MAP			= 0			-- 地图层
LAYER_VIEW 			= 0			-- 一级界面
LAYER_PANEL			= 1			-- 二级界面
LAYER_POPWND		= 2			-- 弹窗
LAYER_DLG			= 3			-- 模态对话框层
LAYER_TOAST 		= 4			-- Tips，通知，公告层
LAYER_DRAG			= 5			-- 拖拽层
LAYER_GUIDE 		= 6			-- 引导层
LAYER_CLICKEFF		= 7			-- 点击特效层
LAYER_LOADING 		= 8			-- 加载层
LAYER_WAITING		= 9			-- 转菊花层
LAYER_TOPEST		= 10		-- 顶层

-- 对象事件
CORE_EVENT = {
	["enter"] = "enter",
	["enterTransitionFinish"] = "enterTransitionFinish",
	["exitTransitionStart"] = "exitTransitionStart",
	["exit"] = "exit",
	["cleanup"] = "cleanup",
}

--关系
RELATION_NONE = 0		--无关系
RELATION_PARTNER = 1	--伙伴关系
RELATION_ENEMY = 2		--敌对关系

--地图阻挡格子大小
MAP_GRID_WIDTH = 16
MAP_GRID_HEIGHT = 16

COLOR = {
	RED = cc.c3b(255,0,0),
	GREEN = cc.c3b(0,255,0),
	BLUE = cc.c3b(0,0,255),
	BLACK = cc.c3b(0,0,0),
	WHITE = cc.c3b(255,255,255),
	YELLOW = cc.c3b(255,255,0),
}

-- 场景
SCENE_CFG = {}
