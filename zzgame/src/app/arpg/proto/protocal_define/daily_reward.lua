return {
	{
		desc = "每日加奖列表",
		name = "req_daily_reward_reward_info",
		reqType = "GET",
	--	domain = "",
		addr = "reward_day/reward_info",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "领取每日嘉奖",
		name = "req_daily_reward_pull",
		reqType = "POST",
	--	domain = "",
		addr = "reward_day/reward_do",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		}
	},
	{
		desc = "每日嘉奖",
		name = "req_daily_reward_reward_list",
		reqType = "POST",
	--	domain = "",
		addr = "activity/Promotion/getRewardList",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		}
	},
}