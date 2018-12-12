local function FixFilePath(filepath)
	local fixedname = string.gsub(filepath, "\\", "/")
	fixedname = string.gsub(fixedname, "//", "/")
	return fixedname
end
local screensize = cc.Director:getInstance():getWinSize()
local _FPS = 60

GAME_CONFIG = {
	FPS = _FPS,								-- 帧率
	SPF = 1/_FPS,							-- 每帧有多少秒
	ShowFps = false,						-- 是否显示帧率
	LOCAL_DIR = FixFilePath(cc.FileUtils:getInstance():getWritablePath().."/ycdata"),	-- 本地缓存路径
	APP_MODE = 1,
	--
	VV_DISABLE_CCOBJECT_SPACE = false,		-- 是否禁用cocos命名空间
	VV_ENABLE_AUTOCLICK_TEST = false,		-- 是否录制点击记录进行自动测试
	VV_DEBUG_EVENT_SOURCE = false,			-- 是否跟踪注册事件时所在的文件及哪一行
	VV_ENABLE_MEMLEAK_CHECK = false,		-- 是否开启内测泄露检测
	VV_ENABLE_AUTO_TEST = false,			-- 是否开启自动测试
	--
	ENABLE_AI_MODULE = false,
	ENABLE_ACTREE_MODULE = false,
}
GAME_CONFIG.SCREEN_W = screensize.width				-- 实际屏幕宽
GAME_CONFIG.SCREEN_H = screensize.height			-- 实际屏幕高
GAME_CONFIG.SCREEN_W_2 = screensize.width/2			-- 实际屏幕宽/2
GAME_CONFIG.SCREEN_H_2 = screensize.height/2		-- 实际屏幕高/2
GAME_CONFIG.DESIGN_W = 720							-- 设计宽
GAME_CONFIG.DESIGN_H = GAME_CONFIG.SCREEN_H			-- 设计高
GAME_CONFIG.DESIGN_W_2 = 360						-- 设计宽/2
GAME_CONFIG.DESIGN_H_2 = GAME_CONFIG.SCREEN_H_2		-- 设计高/2
GAME_CONFIG.VIEW_W = 720
GAME_CONFIG.VIEW_H = 1280
GAME_CONFIG.VIEW_W_2 = 360
GAME_CONFIG.VIEW_H_2 = 640
GAME_CONFIG.HEIGHT_DIFF = GAME_CONFIG.DESIGN_H - GAME_CONFIG.VIEW_H

function FixScreen()
	local screensize = cc.Director:getInstance():getWinSize()
	GAME_CONFIG.SCREEN_W = screensize.width				-- 实际屏幕宽
	GAME_CONFIG.SCREEN_H = screensize.height			-- 实际屏幕高
	GAME_CONFIG.SCREEN_W_2 = screensize.width/2			-- 实际屏幕宽/2
	GAME_CONFIG.SCREEN_H_2 = screensize.height/2		-- 实际屏幕高/2
	GAME_CONFIG.DESIGN_H = GAME_CONFIG.SCREEN_H			-- 设计高
	GAME_CONFIG.DESIGN_H_2 = GAME_CONFIG.SCREEN_H_2		-- 设计高/2
	GAME_CONFIG.HEIGHT_DIFF = GAME_CONFIG.DESIGN_H - GAME_CONFIG.VIEW_H
end

-----------------------------------------------------------------------------------------
local serv_list = {
--		ip					port		desc
	{ "127.0.0.1", 			20013, 		"localhost" },
}
local curServ = serv_list[1]
SERVER_IP = curServ[1]
SERVER_PORT = curServ[2]

-----------------------------------------------------------------------------------------
local SITE_CFG = {
	--测试站
	testor = {
		hotdir = "testor",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://agentapiuser.guocaiapi.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w01",
		Y_OFFSET = 0,
	},
	--试玩站
	shiwan = {
		hotdir = "shiwan",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w02",
		Y_OFFSET = 0,
	},
	--长龙测试
    dragon = {
		hotdir = "dragon",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "http://hddtw01userapi.aikfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w01",
		Y_OFFSET = 0,
	},
	
	--易彩乐
	yicaile = {
		hotdir = "yicaile",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w08",
		Y_OFFSET = -30,
	},
	--中彩网
	zhongcai = {
		hotdir = "zhongcai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w38",
		Y_OFFSET = -170,
	},
	--易博
	yibo = {
		hotdir = "yibo",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w42",
		Y_OFFSET = -70,
	},
	--国彩
	guocai = {
		hotdir = "guocai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w31",
		Y_OFFSET = 0,
	},
	--易彩网
	yicaiwang = {
		hotdir = "yicaiwang",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w50",
		Y_OFFSET = -20,
	},
	--开采网
	kaicai = {
		hotdir = "kaicai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w34",
		Y_OFFSET = -160,
	},
	--易彩堂
	yicaitang = {
		hotdir = "yicaitang",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w36",
		Y_OFFSET = -170,
	},
	--8k站
	k8ycy = {
		hotdir = "k8ycy",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w05",
		Y_OFFSET = -160,
	},
	--全民彩票
	quanmin = {
		hotdir = "quanmin",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w62",
		Y_OFFSET = -170,
	},
	--中彩64
	zongcai64 = {
		hotdir = "zongcai64",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w64",
		Y_OFFSET = 180,
	},
	--彩7
	cai7 = {
		hotdir = "cai7",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w07",
		Y_OFFSET = 0,
	},
	--大爆奖
	dabaojiang = {
		hotdir = "dabaojiang",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w46",
		Y_OFFSET = -80,
	},
	--爱彩
	aicai = {
		hotdir = "aicai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w47",
		Y_OFFSET = 260,
	},
	--新彩票
	xincai = {
		hotdir = "xincai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w44",
		Y_OFFSET = -170,
	},
	--金达彩票
	jinda = {
		hotdir = "jinda",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w66",
		Y_OFFSET = -170,
	},
	--易彩
	yicaiw67 = {
		hotdir = "yicaiw67",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w67",
		Y_OFFSET = 0,
	},
	--千金彩
	w30qianjin = {
		hotdir = "w30qianjin",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w30",
		Y_OFFSET = -170,
	},
	--K彩
	w68kcai = {
		hotdir = "w68kcai",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w68",
		Y_OFFSET = 0,
	},
	--丰宏彩票
	w69 = {
		hotdir = "w69",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w69",
		Y_OFFSET = -170,
	},
	--淘彩网
	w70 = {
		hotdir = "w70",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w70",
		Y_OFFSET = -170,
	},
	--
	w71 = {
		hotdir = "w71",
		ENGINE_BUILD_TYPE = 2,
		SERVER_URL = "https://www.wpub1dkjflsdakjfsdkgdfjsdfj.com",
		HTTP_HEAD_KEY = "AuthGC",
		HTTP_HEAD_VAL_1 = "w71",
		Y_OFFSET = 0,
	},
}

CUR_SITE_NAME = "testor"	--当前站点
CUR_SITE_CFG = SITE_CFG[CUR_SITE_NAME]

ENGINE_BUILD_TYPE = CUR_SITE_CFG.ENGINE_BUILD_TYPE
SERVER_URL = CUR_SITE_CFG.SERVER_URL
HTTP_HEAD_KEY = CUR_SITE_CFG.HTTP_HEAD_KEY
HTTP_HEAD_VAL_1 = CUR_SITE_CFG.HTTP_HEAD_VAL_1

IS_DEBUG_MODE = true	--测试版or发布版（仅作用于脚本层）


-----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------

-- 0 - disable debug info, 1 - less debug info, 2 - verbose debug info
DEBUG = 0

-- use framework, will disable all deprecated API, false - use legacy API
CC_USE_FRAMEWORK = true

-- show FPS on screen
CC_SHOW_FPS = true

-- disable create unexpected global variable
CC_DISABLE_GLOBAL = false

-- for module display
CC_DESIGN_RESOLUTION = {
    width = GAME_CONFIG.DESIGN_W,
    height = GAME_CONFIG.DESIGN_H,
    autoscale = "FIXED_WIDTH",
}
