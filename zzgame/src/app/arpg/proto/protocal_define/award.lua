return {
	{
		desc = "玩家信息",
		name = "req_award_playerinfo",
		reqType = "GET",
	--	domain = "",
		addr = "home/win_info",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "uid", "string" },
			{ "type", "string", true },
		}
	},
	{
		desc = "中奖信息",
		name = "req_award_today",
		reqType = "GET",
	--	domain = "",
		addr = "home/today_win",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		}
	},
	{
		desc = "昨日奖金榜",
		name = "req_award_yestoday",
		reqType = "GET",
	--	domain = "",
		addr = "home/yesterday_win",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		}
	},
}