return{
    {
		desc = "聊天记录",
		name = "req_interactive_chat_index",
		reqType = "GET",
	--	domain = "",
		addr = "interactive/chat/index",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"time","int",true},
        }
	},
    {
		desc = "获取ws地址",
		name = "req_interactive_chat_get_ws_url",
		reqType = "GET",
	--	domain = "",
		addr = "interactive/chat/get_ws_url",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
		desc = "今日战绩",
		name = "req_interactive_chat_share_standings",
		reqType = "POST",
	--	domain = "",
		addr = "interactive/chat/share_standings",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
		desc = "分享注单",
		name = "req_interactive_chat_share_bets",
		reqType = "POST",
	--	domain = "",
		addr = "interactive/chat/share_bets",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
		desc = "跟投",
		name = "req_orders_bet3_gid",
		reqType = "POST",
	--	domain = "",
		addr = "orders/bet3/gid",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
		desc = "最新计划",
		name = "req_interactive_chat_get_last_plan",
		reqType = "GET",
	--	domain = "",
		addr = "interactive/chat/get_last_plan",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
		desc = "排行榜",
		name = "req_home_yesterday_win",
		reqType = "GET",
	--	domain = "",
		addr = "home/yesterday_win",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
        desc = "长龙助手我要投注",
		name = "req_dragon_plays",
		reqType = "GET",
	--	domain = "",
		addr = "dragon/plays",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
    },
    {
        desc = "长龙助手最近投注",
		name = "req_dragon_data",
		reqType = "GET",
	--	domain = "",
		addr = "dragon/data",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
    },
    {
        desc = "返回服务器期号",
		name = "req_home_kithe_plan",
		reqType = "GET",
	--	domain = "",
		addr = "home/kithe_plan",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}      
    },
    {
        desc = "返回服务器时间戳",
		name = "req_home_now_stamp",
		reqType = "GET",
	--	domain = "",
		addr = "home/now_stamp",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}      
    },
    {
        desc = "所有倒计时",
		name = "req_home_game_plan",
		reqType = "GET",
	--	domain = "",
		addr = "home/game_plan",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}      
    },
}
