-------------------------
-- 代理相关协议
-------------------------
module("proto",package.seeall)

--
function on_req_agent_check_agent_register(recvdata)
	
end

function on_req_agent_today_report(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentReportToday(recvdata)
end

function on_req_agent_yestoday_report(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentReportYester(recvdata)
end

function on_req_agent_cur_month_report(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentReportMonth(recvdata)
end

function on_req_agent_last_month_report(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentReportLastMonth(recvdata)
end

function on_req_agent_junior_report_today(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentRepotTodayData(recvdata)
end

function on_req_agent_junior_report_yestoday(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentRepotYesterData(recvdata)
end

function on_req_agent_junior_report_cur_month(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentRepotMonthData(recvdata)
end

function on_req_agent_junior_report_last_month(recvdata)
	ClsAgentDataMgr.GetInstance():SaveAgentRepotLastMonthData(recvdata)
end

function on_req_agent_invite_code_list(recvdata)
	
end

function on_req_agent_junior_member(recvdata)
	
end

function on_req_agent_bet_records(recvdata)
	
end

function on_req_agent_transaction_detail(recvdata)
	
end

function on_req_create_invite_code(recvdata)

end

function on_req_delete_invite_code(recvdata)

end

function on_req_agent_charge_records(recvdata)

end

function on_req_agent_withdraw_records(recvdata)

end

function on_req_agent_bet_detail(recvdata)
    ClsAgentDataMgr.GetInstance():SaveAgentBetDetail(recvdata)
end

function on_req_bonus_detailed_get_list(recvdata)
    
end

function on_req_invite_code_list(recvdata)
	ClsAgentDataMgr.GetInstance():SaveRebate(recvdata)
end