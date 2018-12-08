return {
	{
		desc = "代理权限验证",
		name = "req_agent_check_agent_register",
		reqType = "GET",
	--	domain = "",
		addr = "agent/check_agent_register",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "代理报表-今日报表",
		name = "req_agent_today_report",
		reqType = "POST",
	--	domain = "",
		addr = "agent/today_report",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username","string"}
        }
	},
	{
		desc = "代理报表-昨日报表",
		name = "req_agent_yestoday_report",
		reqType = "POST",
	--	domain = "",
		addr = "agent/yesterday_report",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username","string"}
        }
	},
	{
		desc = "代理报表-本月报表",
		name = "req_agent_cur_month_report",
		reqType = "POST",
	--	domain = "",
		addr = "agent/cur_month_report",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username","string"}
        }
	},
	{
		desc = "代理报表-上月报表",
		name = "req_agent_last_month_report",
		reqType = "POST",
	--	domain = "",
		addr = "agent/last_month_report",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username","string"}
        }
	},
	
	{
		desc = "下级报表-今日报表",
		name = "req_agent_junior_report_today",
		reqType = "POST",
	--	domain = "",
		addr = "agent/junior_report_today",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"uid","string"},
        }
	},
	{
		desc = "下级报表-昨日报表",
		name = "req_agent_junior_report_yestoday",
		reqType = "POST",
	--	domain = "",
		addr = "agent/junior_report_yesterday",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"uid","string"},
        }
	},
	{
		desc = "下级报表-本月报表",
		name = "req_agent_junior_report_cur_month",
		reqType = "POST",
	--	domain = "",
		addr = "agent/junior_report_cur_month",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"uid","string"},
        }
	},
	{
		desc = "下级报表-上月报表",
		name = "req_agent_junior_report_last_month",
		reqType = "POST",
	--	domain = "",
		addr = "agent/junior_report_last_month",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"uid","string"},
        }
	},
	
	{
		desc = "下级开户-邀请码",
		name = "req_agent_invite_code_list",
		reqType = "POST",
	--	domain = "",
		addr = "agent/invite_code_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "type", "int" },
		}
	},
    {
        desc = "生成邀请码",
        name = "req_create_invite_code",
        reqType = "POST",
        addr = "agent/create_invite_code",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"type","int"},
            {"ssc","string"},
            {"k3","string"},
            {"11x5","string"},
            {"fc3d","string"},
            {"pl3","string"},
            {"pk10","string"},
            {"lhc","string"},
        }
    },
	{
		desc = "会员管理",
		name = "req_agent_junior_member",
		reqType = "POST",
	--	domain = "",
		addr = "agent/junior_member",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			--{ "type", "string" },  -- 0:会员  1:玩家
            {"uid","string"},
		}
	},
	
	{
		desc = "代理-投注记录",
		name = "req_agent_bet_records",
		reqType = "POST",
	--	domain = "",
		addr = "agent_bet_detail/get_bet_list",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username", "string"},
			{ "between_day", "int" },  -- 0:今天 1:昨天 7:7天
			{ "index", "int" }, 
			{ "type", "int" },   -- 0: 全部 1:已中奖 5:未中奖  4:等待开奖
		}
	},
	{
        desc = "代理-投注详情",
        name = "req_agent_bet_detail",
        reqType = "POST",
        addr = "agent_bet_detail/get_game_bet_detail",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"order_num","string"},
        }
    },
	{
		desc = "代理-交易明细",
		name = "req_agent_transaction_detail",
		reqType = "POST",
	--	domain = "",
		addr = "agent/transaction_detail",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
            {"username","string"},
			{ "between_day", "string" },  -- 0:今天 1:昨天 7:7天
			{ "index", "string" }, 
			{ "type", "string" }, 
		}
	},
    {
        desc = "代理-充值记录",
        name = "req_agent_charge_records",
        reqType = "POST",
        addr = "agent/charge_records",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"username","string"},
            { "between_day", "string" },  -- 0:今天 1:昨天 7:7天
			{ "index", "string" }, 
			{ "type", "string" }, 
        }
    },
    {
        desc = "代理-提现记录",
        name = "req_agent_withdraw_records",
        reqType = "POST",
        addr = "agent/withdraw_records",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"username","string"},
            { "between_day", "string" },  -- 0:今天 1:昨天 7:7天
			{ "index", "string" }, 
			{ "type", "string" }, 
        }
    },
    {
        desc = "删除邀请码",
        name = "req_delete_invite_code",
        reqType = "POST",
        addr = "agent/delete_invite_code",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"invite_code","string"},
        }
    },
    {
        desc = "返点赔率表",
        name = "req_bonus_detailed_get_list",
        reqType = "GET",
        addr = "user/bonus_detailed/get_list",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {
            {"type","string"},
        }
    },
    {
        desc = "自身返点",
        name = "req_invite_code_list",
        reqType = "POST",
        addr = "agent/invite_code_list",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {}
    },
}