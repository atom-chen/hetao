-------------------------
-- 奖励协议
-------------------------
module("proto",package.seeall)

--玩家信息
function on_req_award_playerinfo(recvdata, tArgs)
	ClsPlayerInfoMgr.GetInstance():SavePlayerInfoData(tArgs.uid, tArgs.type, recvdata and recvdata.data)
end

--中奖信息
function on_req_award_today(recvdata)
	clsFindMgr.GetInstance():SaveTodayRewardData(recvdata.data)
end

--昨日奖金榜
function on_req_award_yestoday(recvdata)
	clsFindMgr.GetInstance():SaveYesterRewardData(recvdata.data)
end
