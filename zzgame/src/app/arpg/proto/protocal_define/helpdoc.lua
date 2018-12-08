return {
	{
		desc = "网站信息文章内容",
		name = "req_helpdoc_site_info",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/get_game_article_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
		}
	},
	{
		desc = "玩法规则",
		name = "req_helpdoc_play_rule",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/h5_games_rules_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string", true },
			{ "type", "string", true },
		}
	},
}