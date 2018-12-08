return {
	{
		desc = "等级机制列表",
		name = "req_grade_grade_rule_list",
		reqType = "POST",
	--	domain = "",
		addr = "activity/Promotion/getGradeList",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "领取晋级奖励",
		name = "req_grade_uplevel_award",
		reqType = "POST",
	--	domain = "",
		addr = "user/grade_mechanism/rewardDo",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "用户等级相关信息",
		name = "req_grade_grade_info",
		reqType = "POST",
	--	domain = "",
		addr = "user/grade_mechanism/getUserGrade",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "优惠活动等级晋级图片地址",
		name = "req_grade_uplevel_img",
		reqType = "GET",
	--	domain = "",
		addr = "activity/promotion/getGradeImg",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
        desc = "活动列表",
        name = "req_activity_list",
        reqType = "GET",
        addr = "activity/Promotion/get_activity_list",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"show_way","string"}
        }
    },
}