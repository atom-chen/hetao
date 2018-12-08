return {
	{
		desc = "玩法下注",
		name = "req_bet_xiazhu",
		reqType = "POST",
	--	domain = "",
		addr = "orders/bet",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "bets", "string" },
		},
		urlparams = {
			{ "gid", "string" },
			{ "kithe", "string", true },
		},
	},
	{
		desc = "玩法追号下注",
		name = "req_bet_zhuihao_xiazhu",
		reqType = "POST",
	--	domain = "",
		addr = "orders/bets2",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "bets", "string" },
			{ "issues", "string" },
		},
		urlparams = {
			{ "gid", "string" },
		},
	},
	{
		desc = "注单撤消",
		name = "req_bet_cancel_xiazhu",
		reqType = "POST",
	--	domain = "",
		addr = "orders/cancel",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "order_num", "string" },
		},
		urlparams = {
			{ "gid", "string" },
		},
	},
	{
		desc = "游戏状态查询",
		name = "req_bet_game_state",
		reqType = "GET",
	--	domain = "",
		addr = "open_time/get_games_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "gid", "int" },
		},
	},
	{
		desc = "开奖结果查询",
		name = "req_bet_open_result",
		reqType = "GET",
	--	domain = "",
		addr = "Open_result",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "gid", "int" },
		},
	},
	{
		desc = "游戏菜单",
		name = "req_game_menu",
		reqType = "GET",
	--	domain = "",
		addr = "play/play",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {},
		urlparams = { 
			{ "gametype", "string" }
		}
	},
	{
		desc = "球号赔率",
		name = "req_game_ballandrate",
		reqType = "GET",
	--	domain = "",
		addr = "play/products",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {},
		urlparams = { 
			{ "gametype", "string" }
		}
	},
}