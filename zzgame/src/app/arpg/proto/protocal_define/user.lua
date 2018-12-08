return {
	{
		desc = "设置-银行卡列表",
		name = "req_user_bankcard_list",
		reqType = "POST",
	--	domain = "",
		addr = "user/user/bank_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "设置-绑定银行卡",
		name = "req_user_bind_bankcard",
		reqType = "POST",
	--	domain = "",
		addr = "user/user_card/card_add",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "bank_id", "string" },
			{ "bank_name", "string", true },
			{ "bank_pwd", "string" },
			{ "num", "string" },
			{ "address", "string" },
			{ "phone", "string", true },
		}
	},
	{
		desc = "设置-绑定微信支付宝",
		name = "req_user_bind_wx_zfb",
		reqType = "POST",
	--	domain = "",
		addr = "user/user_card/card_add",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "bank_id", "string" },
			{ "bank_name", "string", true },
			{ "bank_pwd", "string", true },
			{ "num", "string" },
			{ "file", "string" },
			{ "address", "string", true },
			{ "phone", "string", true },
		}
	},
	{
		desc = "设置-绑定时是否需要填入真实姓名、手机号等",
		name = "req_user_bind_needinfo",
		reqType = "POST",
	--	domain = "",
		addr = "user",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {},
		urlparams = {
			{ "bank_name", "string" },
		}
	},
	{
		desc = "余额",
		name = "req_user_balance",
		reqType = "POST",
	--	domain = "",
		addr = "user/user/user_balance",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "设置-已绑定银行卡",
		name = "req_user_binded_banks",
		reqType = "POST",
	--	domain = "",
		addr = "user/user_card/user_card",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "提现数据",
		name = "req_user_tixian",
		reqType = "POST",
	--	domain = "",
		addr = "pay/out_mamage/out_show",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "账户明细",
		name = "req_user_zhanghu_mingxi",
		reqType = "GET",
	--	domain = "",
		addr = "user/cash_list/get_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "page", "int" },
			{ "rows", "string", true },
			{ "type", "string" },
			{ "time_start", "string" },
            { "time_end", "string"}
		}
	},
    {
        desc = "我的收藏",
        name = "req_user_get_favorite",
        reqType = "GET",
        addr = "user/Favorite/get_favorite",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
		}
    },
    {
        desc = "修改我的收藏",
        name = "req_user_set_favorite",
        reqType = "POST",
        addr = "user/Favorite/set_favorite",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"gid","string"},
            {"status","string"},
		}
    },
	{
		desc = "充值记录",
		name = "req_user_chongzhi_record",
		reqType = "GET",
	--	domain = "",
		addr = "user/income_record/get_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "time_start", "string" },
			{ "time_end", "string" },
			{ "rows", "string" },
			{ "page", "string" },
			{ "type", "string", true },
		}
	},
	{
		desc = "充值记录-类型",
		name = "req_user_chongzhi_record_type",
		reqType = "GET",
	--	domain = "",
		addr = "user/income_record/get_type",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "今日盈亏",
		name = "req_user_today_earn",
		reqType = "GET",
	--	domain = "",
		addr = "user/User_info/profit",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "个人信息-个人资料",
		name = "req_user_info",
		reqType = "GET",
	--	domain = "",
		addr = "user/user_info/info",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "个人信息-等级头衔",
		name = "req_user_nobility",
		reqType = "GET",
	--	domain = "",
		addr = "user/user_info/nobility",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "个人信息-修改资料",
		name = "req_user_update_info",
		reqType = "POST",
	--	domain = "",
		addr = "user/user_info/update_info",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "birthday", "string", true },
			{ "phone", "string" },
			{ "nickname", "string" },
			{ "sex", "string" },
			{ "email", "string" },
			{ "modify", "string" },
		}
	},
	{
		desc = "个人信息-上传头像",
		name = "req_user_upload_headimg",
		reqType = "POST",
	--	domain = "",
		addr = "user/user/user_head",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "file", "string" },
		}
	},
	{
		desc = "收款中心-绑卡列表",
		name = "req_user_shoukuan_binded_cards",
		reqType = "GET",
	--	domain = "",
		addr = "user/user_card/new_user_card",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "分享页面",
		name = "req_user_share",
		reqType = "GET",
	--	domain = "",
		addr = "home/get_fenxiang",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
    {
        desc = "投注记录",
        name = "req_user_bet_record_get_list",
        reqType = "GET",
        addr = "user/bet_record/get_list",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"type","string"},
            {"page","number"},
        }
    },
    {
        desc = "提现记录",
        name = "req_user_Payout_record_get_payout_list",
        reqType = "GET",
        addr = "user/Payout_record/get_payout_list",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"type","string"},
            {"time_start","string"},
            {"time_end","string"},
            {"page", "number"}
        }
    },
    {
        desc = "登陆密码修改",
        name = "req_chang_login_pwd",
        reqType = "POST",
        addr = "user/user/chang_login_pwd",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"pwd","string"},
            {"new_pwd","string"},
        }
    },
    {
        desc = "资金密码修改",
        name = "req_bank_pwd_chang",
        reqType = "POST",
        addr = "user/user/bank_pwd_chang",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"bank_pwd","string"},
            {"new_pwd","string"},
        }
    },
    {
        desc = "token刷新",
        name = "req_refresh_token",
        reqType = "GET",
        addr = "user/user/refresh",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {},
    },
}