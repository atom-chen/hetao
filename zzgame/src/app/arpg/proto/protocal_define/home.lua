return {
	{
		desc = "首页-首页彩种",
		name = "req_home_caizhong",
		reqType = "GET",
	--	domain = "",
		addr = "open_time/get_games_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "new_hot", "string" },
		}
	},
	{
		desc = "首页-配置信息",
		name = "req_home_homedata",
		reqType = "GET",
	--	domain = "",
		addr = "home/getHomeData",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "show_location","int",true }
		}
	},
	{
		desc = "首页-更多彩种",
		name = "req_home_more_caizhong",
		reqType = "GET",
	--	domain = "",
		addr = "open_time/get_games_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "hot", "string" },
		}
	},
	{
		desc = "系统信息",
		name = "req_home_sysinfo",
		reqType = "GET",
	--	domain = "",
		addr = "system/index",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "app_type", "string" },
		}
	},
	{
		desc = "首页-如何领奖",
		name = "req_home_tip_award_way",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/get_game_article_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
		}
	},
	{
		desc = "规则",
		name = "req_get_game_article_content",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/get_game_article_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
		}
	},
	{
		desc = "首页-如何提款",
		name = "req_home_tip_tikuan",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/get_game_article_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
		}
	},
    {
        desc = "公告信息",
        name  = "req_home_getnotice",
        reqType = "GET",
        addr = "notice/getNotice",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"show_location","int"},
            {"type", "int"},
        }
    },
}