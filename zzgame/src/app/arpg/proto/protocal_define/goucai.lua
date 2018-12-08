return {
	{
		desc = "获取主页/购彩/开奖游戏列表",
		name = "req_goucai_gamelist",
		reqType = "GET",
	--	domain = "",
		addr = "open_time/get_games_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "gid", "int", true },
			{ "use", "string", true },
			{ "ctg", "string", true },
			{ "type", "string", true },
			{ "hot", "int", true },
			{ "new_hot", "int", true },
		}
	},
	{
		desc = "获取购彩游戏列表",
		name = "req_goucai_all_games",
		reqType = "GET",
	--	domain = "",
		addr = "open_time/get_games_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "use", "string" },
		}
	},
	{
		desc = "获取游戏玩法列表",
		name = "req_goucai_game_wanfa_list",
		reqType = "GET",
	--	domain = "",
		addr = "games/play",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		urlparams = {
			{ "gid", "int" },
		}
	},
	{
		desc = "获取游戏球号和赔率列表",
		name = "req_goucai_game_qiuhao_peilv_list",
		reqType = "GET",
	--	domain = "",
		addr = "games/products",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		urlparams = {
			{ "gid", "int" },
			{ "tid", "int" },
		}
	},
	{
		desc = "玩法赔率整和(按照大分类)",
		name = "req_goucai_bet_rate",
		reqType = "GET",
	--	domain = "",
		addr = "play/bet_rate/s_k3",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {},
		urlparams = {
			{ "tmp", "string" },
		}
	},
	{
		desc = "六合彩颜色",
		name = "req_goucai_game_lhc_sx",
		reqType = "GET",
	--	domain = "",
		addr = "games/lhc_sx",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {},
		urlparams = {},
	},
	{
		desc = "走势图表",
		name = "req_goucai_game_trend_list",
		reqType = "GET",
	--	domain = "",
		addr = "activity/game_trend/get_game_trend_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "gid", "int" },	
		},
		urlparams = {},
	},
}