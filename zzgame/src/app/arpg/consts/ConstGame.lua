module("const", package.seeall)

-- 登录状态
LOGON_STATE = {
	ready 	= "ready",				--未登录
	regist 	= "regist",				--注册中
	regist_succ = "regist_succ",	--注册成功
	regist_fail = "regist_fail",	--注册失败
	login 	= "login",				--登录中
	login_succ = "login_succ",		--登录成功
	login_fail = "login_fail",		--登录失败
	kicked 	= "kicked",				--账号被踢
    logout  = "logout",             --退出登录
}

--性别
GENDER = {
	MALE       = "1",		--男性
	FEMALE     = "2",		--女性
}

--游戏类型
GAME_TYPE = {
	["ssc"] 	= { sortidx=2, typeid = "ssc", 		client_gamename = "时时彩",		ViewClass = "clsGameSscView",	icon_name = "icon_ssc", },
	["lhc"] 	= { sortidx=4, typeid = "lhc", 		client_gamename = "六合彩",		ViewClass = "clsGameLhcView",	icon_name = "icon_lhc", },
	["pcdd"] 	= { sortidx=8, typeid = "pcdd", 	client_gamename = "PC蛋蛋",		ViewClass = "clsGamePcddView",	icon_name = "icon_pcdd", },
	["yb"] 		= { sortidx=7, typeid = "yb", 		client_gamename = "低频彩",		ViewClass = "clsGameYbView",	icon_name = "icon_yb", },
	["k3"] 		= { sortidx=1, typeid = "k3", 		client_gamename = "快三",		ViewClass = "clsGameK3View",	icon_name = "icon_k3", },
	["11x5"] 	= { sortidx=3, typeid = "11x5", 	client_gamename = "11选5",		ViewClass = "clsGame11x5View",	icon_name = "icon_11x5", },
	["kl10"] 	= { sortidx=6, typeid = "kl10", 	client_gamename = "快乐拾",		ViewClass = "clsGameKL10View",	icon_name = "icon_kl10", },
	["pk10"] 	= { sortidx=5, typeid = "pk10", 	client_gamename = "PK10",		ViewClass = "clsGamePk10View",	icon_name = "icon_pk10", },
}
for k, v in pairs(GAME_TYPE) do assert(k==v.typeid) end

MIN_BET_MONEY = 0.1
--MAX_BET_MONEY = 1000000
MAX_BET_LENGTH = 9

--六合彩
GAME_LHC_COLOR = {
	blue = cc.c3b(13,134,227),
	green = cc.c3b(55,191,79),
	red = cc.c3b(244,67,54),
	white = cc.c3b(255,255,255),
	gray = cc.c3b(99,99,99),
}

BILL_TYPE = {
	SINGLE = "SINGLE",
	MxN = "MxN",
	MzN = "MzN",
	JustN = "JustN",
	ZHIXUAN = "ZHIXUAN",
	MULTY_GRP = "MULTY_GRP",
	LHC_HX = "LHC_HX",
}
