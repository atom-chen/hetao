-------------------------
-- 购彩协议
-------------------------
module("proto",package.seeall)

--每日加奖列表
function on_req_daily_reward_reward_info(recvdata)
	clsActiveMgr.GetInstance():SaveRewardData(recvdata)
end

--领取每日嘉奖
function on_req_daily_reward_pull(recvdata)
	local bCan = true
	if recvdata and recvdata.code == 200 then bCan = false end
	clsActiveMgr.GetInstance():SetCanAward(recvdata)
end

--每日嘉奖
function on_req_daily_reward_reward_list(recvdata)
	
end
