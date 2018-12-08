return {
	{
		desc = "红包活动入口",
		name = "req_redbag_openstate",
		reqType = "GET",
	--	domain = "",
		addr = "red_bag/index",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			
		},
		urlparams = {
			
		},
	},
	{
		desc = "红包详情",
		name = "req_redbag_detail",
		reqType = "GET",
	--	domain = "",
		addr = "red_bag/user_detail",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "red_id", "string" }
		},
		urlparams = {
			
		},
	},
	{
		desc = "抢红包",
		name = "req_redbag_grab",
		reqType = "POST",
	--	domain = "",
		addr = "red_bag/grab_red_bag",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
		},
		urlparams = {
			
		},
	},
	{
		desc = "红包排行榜",
		name = "req_redbag_ranklist",
		reqType = "GET",
	--	domain = "",
		addr = "red_bag/bag_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		},
		urlparams = {
			
		},
	},
}